Subject: Re: Hopefully a simple question on /proc/pid/mem
References: <Pine.GSO.4.21.0104301457010.5737-100000@weyl.math.psu.edu> <Pine.LNX.3.96.1010430145934.30664D-100000@kanga.kvack.org> <20010430225802.H26638@redhat.com> <m166flhnvy.fsf@frodo.biederman.org> <20010501103631.J26638@redhat.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 01 May 2001 09:16:48 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 1 May 2001 10:36:31 +0100"
Message-ID: <m1u235p09r.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Alexander Viro <viro@math.psu.edu>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Mon, Apr 30, 2001 at 07:13:53PM -0600, Eric W. Biederman wrote:
> 
> > > Hint: think about what happens if you make a shared mapping of a
> > > private proc/*/mem region... 
> > 
> > Now that we have reusable swap cache pages we could make it work
> > correctly, except for the case of the first write a private mapping of
> > file.    Not that we would want to...
> 
> Think about fork.  If a parent forks and then touches a private page
> before the child does, it's the parent which gets a new page.  The
> supposed shared mmap of the parent now points to the child's page, not
> the parent's.  COW basically just can't do the right thing if a page
> is both shared and private at the same time.

Right.  This is a different context but it has the same properties of
what I was thinking of.  The fact that fork has the problem too,
means it's definitely not doable right now.  At least not with the
intuitive semantics.  If we either denied shared mappings of private
mappings or simply promoted them to shared mappings we could easily do a
non-buggy implementation. 

The problem isn't really COW, the copy on write is easy.  The hard
part it to appropriately share the resulting copy.  If we really had
to do this it might be possible by playing with the open method in the
vma_operations.  Implementation wise I think a shared private mapping
of a file is really a harder case than fork COW pages.

I think it is a better argument that since nothing except a mmap of
/proc/pid/mem needs the complexity of simultaneously shared and
private mappings, it isn't worth supporting them.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
