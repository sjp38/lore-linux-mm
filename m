Message-ID: <42941E5D.5060606@engr.sgi.com>
Date: Wed, 25 May 2005 01:42:37 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org> <428E6427.7060401@engr.sgi.com> <429217F8.5020202@mwwireless.net> <4292B361.80500@engr.sgi.com> <Pine.LNX.4.62.0505241356320.2846@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505241356320.2846@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Steve Longerbeam <stevel@mwwireless.net>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 23 May 2005, Ray Bryant wrote:
> 
> 
>>We need to take a different migration action based on which case we
>>are in:
>>
>>(1)  Migrate all of the pages.
>>(2)  Migrate the non-shared pages.
>>(3)  Migrate none of the pages.
>>
>>So we need some external way for the kernel to be told which kind of
>>mapped file this is.  That is why we need some kind of interface for
>>the user (or admininistrator) to tell us how to classify each shared
>>mapped file.
> 
> 
> Sorry I am a bit late to the party and I know you must have said this
> before but what is the reason again not to use the page reference count to 
> determine if a page is shared? Maybe its possible to live with some 
> restrictions that the use of the page reference count brings.
> 
> Seems that touching a filesystem and the ELF headers is way off from the 
> vm.
> 
> 
> 

Christoph,

I assume you are suggesting that we use the page_mapcount() to detect
pages that shared and then not migrating those pages?  The problem with
that is what do you do about the case where a user program mmap()'s a data
file, then forks a bunch of times, and then we need to migrate that job.
The data file belongs only to the processes that we are migrating, but
it will have a page_mapcount() equal to the number of processes.   So
it should be migrated.

Now a workable solution might be that we decide to not migrate shared
pages that are executable (or part of a vma marked executable).  That
would handle the shared library and shared (system) executable case
quite nicely.  It wouldn't handle the case of a shared user executable
that is only used by the processes being migrated, since it will be
shared an executable, but should be migrated, and we will decide by
the above rule not to migrate it.

Executables are small potatoes in most cases, however, the real issue
is to get the data pages to be migrated.

Another irritating corner case is that of r/o shared data files mapped
in from /usr/lib (National language support does this).  We could say
that if the vma is read only and the page shared, we would not migrate
it either.  User mapped files will typically be read/write, I would
tbink.

Combining all of this with some fixed heuristics (i. e. files in
/bin and /usr/bin are shared executables) might be workable.  It
always bothers me, in those cases though, to imagine having such
a fixed list of directories encoded in the kernel and not configurable.
I suppose one could have a /proc file where one put such a directory/
file list, but that seems messy.


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
