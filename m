Date: Fri, 24 Apr 1998 21:37:45 +0100
Message-Id: <199804242037.VAA01182@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fixing private mappings
In-Reply-To: <m1g1j4nqll.fsf@flinx.npwt.net>
References: <Pine.LNX.3.95.980423105842.15346A-100000@as200.spellcast.com>
	<m1g1j4nqll.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Apr 1998 17:03:02 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

>>> Definition of Private Mappings:
>>> A private mapping is a copy-on-write mapping of a file.  
>>> 
>>> That is if the file is written to after the mapping is established,
>>> the contents of the mapping will always remain what the contents of
>>> the file was at the time of the private mapping.

BL> Note: 'the initial write reference will create a private copy' -- not
BL> the act of reading or mapping.

> Right.  That is probably the only reasonable way to implement it.

Indeed.

> I stated it as I did so what happens if another process writes to the
> file is clear.  Another process writing to the file will be the
> `initial write reference'.

No --- in the context of a MAP_PRIVATE mapping, only in-memory writes to
the privately mapped virtual address space count as write references.  

> So logically MAP_PRIVATE gives you a snapshot of the contents of a
> file.   Not that it actually takes that snapshot...

No, it shouldn't --- it maps the file into the process address space,
and all updates to the file are reflected in the process's virtual
memory copy.  Only if the process tries to write to the file is the COW
activated.

> Possibly I'm failing to see the difference in the definitions?

Yep.  MAP_PRIVATE mappings preserve the correspondance over writes to
the file by any mechanism other than modifying the mapping itself.

Note that the semantics are relaxed a bit if we have non-page-aligned
private maps, in that the correspondance between the mapped image and
the file contents is no longer always preserved if the file is updated.

> The problem is update_vm_cache only looks currently for the primary
> inode page.  The one at (offset%PAGE_SIZE)==0.  So the other page at
> offset%PAGE_SIZE==1k is not updated.

Yep, but we are not required to support non-page-aligned maps at all, so
hacking it for special read-only cases is no big deal.  Doing a search
for all overlapping mapped pages would be far too slow.

--Stephen
