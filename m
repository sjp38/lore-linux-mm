Message-ID: <42989885.4020603@engr.sgi.com>
Date: Sat, 28 May 2005 11:12:53 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org> <428E6427.7060401@engr.sgi.com> <429217F8.5020202@mwwireless.net> <4292B361.80500@engr.sgi.com> <Pine.LNX.4.62.0505241356320.2846@graphe.net> <42941E5D.5060606@engr.sgi.com> <20050528084026.GA18380@infradead.org>
In-Reply-To: <20050528084026.GA18380@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Lameter <christoph@lameter.com>, Steve Longerbeam <stevel@mwwireless.net>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Wed, May 25, 2005 at 01:42:37AM -0500, Ray Bryant wrote:
> 
>>Now a workable solution might be that we decide to not migrate shared
>>pages that are executable (or part of a vma marked executable).  That
>>would handle the shared library and shared (system) executable case
>>quite nicely.  It wouldn't handle the case of a shared user executable
>>that is only used by the processes being migrated, since it will be
>>shared an executable, but should be migrated, and we will decide by
>>the above rule not to migrate it.
> 
> 
> I don't think that's a good idea.  It would place arbitrary policy into
> the kernel, something we try to avoid.
> 
> 
> 

In general, I agree, but I would argue this is less of a policy decision than
it is a performance optimization.  That's because part of the fix is to also
allow user space to override the migration decision using mbind() to explictly
set the migration attributes of each memory object.  So, we could make
the user do that for each object (no kernel "policy" at all), or we could fix
it so that the kernel does the right thing in most cases, and then user space
only has to use the mbind() system call to fix up the cases that the
kernel doesn't get right.

In the current instantiation of this, that means that user space only has
to use the mbind() call to fix the migration attributes for:

(1)  The user executable.
(2)  User data files mapped read-only.

All of the other vma's will be handled correctly.  (It is expected that the
user space migration library will deal with these cases.)

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
