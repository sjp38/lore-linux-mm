Date: Wed, 4 Jun 2008 01:29:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/21] hugetlb multi size, giant hugetlb support, etc
Message-Id: <20080604012938.53b1003c.akpm@linux-foundation.org>
In-Reply-To: <20080603095956.781009952@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, 03 Jun 2008 19:59:56 +1000 npiggin@suse.de wrote:

> Hi,
> 
> Here is my submission to be merged in -mm. Given the amount of hunks this
> patchset has, and the recent flurry of hugetlb development work, I'd hope to
> get this merged up provided there aren't major issues (I would prefer to fix
> minor ones with incremental patches). It's just a lot of error prone work to
> track -mm when multiple concurrent development is happening.
> 
> Patch against latest mmotm.
> 
> 
> What I have done for the user API issues with this release is to take the
> safe way out and just maintain the existing hugepages user interfaces
> unchanged. I've integrated Nish's sysfs API to control the other huge
> page sizes.
> 
> I had initially opted to drop the /proc/sys/vm/* parts of the changes, but
> I found that the libhugetlbfs suite continued to have failures, so I
> decided to revert the multi column /proc/meminfo changes too, for now.
> 
> I say for now, because it is very easy to subsequently agree on some
> extention to the API, but it is much harder to revert such an extention once
> it has been made. I also think the main thing at this point is to get the
> existing patchset merged. User API changes I really don't want to worry
> with at the moment... point is: the infrastructure changes are a lot of
> work to code, but not so hard to get right; the user API changes are
> easy to code but harder to get right.
> 
> New to this patchset: I have implemented a default_hugepagesz= boot option
> (defaulting to the arch's HPAGE_SIZE if unspecified), which can be used to
> specify the default hugepage size for all /proc/* files, SHM, and default
> hugetlbfs mount size. This is the best compromise I could find to keep back
> compatibility while allowing the possibility to try different sizes with
> legacy code.
> 
> One thing I worry about is whether the sysfs API is going to be foward
> compatible with NUMA allocation changes that might be in the pipe.
> This need not hold up a merge into -mm, but I'd like some reassurances
> that thought is put in before it goes upstream.
> 
> Lastly, embarassingly, I'm not the best source of information for the
> sysfs tunables, so incremental patches against Documentation/ABI would
> be welcome :P
> 

I think I'll duck this iteration.  Partly because I was unable to work
out how nacky the feedback for 14/21 was, but mainly because I don't
know what it all does, because none of the above explains this.

Can't review it if I don't know what it's all trying to do.

Things like this:

: Large, but rather mechanical patch that converts most of the hugetlb.c
: globals into structure members and passes them around.
: 
: Right now there is only a single global hstate structure, but 
: most of the infrastructure to extend it is there.

OK, but it didn't tell us why we want multiple hstate structures.

: Add basic support for more than one hstate in hugetlbfs
: 
: - Convert hstates to an array
: - Add a first default entry covering the standard huge page size
: - Add functions for architectures to register new hstates
: - Add basic iterators over hstates

And neither did that.

One for each hugepage size, I'd guess.

: Add support to have individual hstates for each hugetlbfs mount
: 
: - Add a new pagesize= option to the hugetlbfs mount that allows setting
: the page size
: - Set up pointers to a suitable hstate for the set page size option
: to the super block and the inode and the vma.
: - Change the hstate accessors to use this information
: - Add code to the hstate init function to set parsed_hstate for command
: line processing
: - Handle duplicated hstate registrations to the make command line user proof

Nope, wrong guess.  It's one per mountpoint.

So now I'm seeing (I think) that the patchset does indeed implement
multiple page-size hugepages, and that it it does this by making an
entire hugetlb mountpoint have a single-but-settable pagesize.

All pretty straightforward stuff, unless I'm missing something.  But
please do spell it out because surely there's stuff in here which I
will miss from the implementation and the skimpy changelog.

Please don't think I'm being anal here - changelogging matters.  It
makes review more effective and it allows reviewers to find problems
which they would otherwise have overlooked.  btdt, lots of times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
