Subject: Re: [PATCH/RFC 10/11] Shared Policy: per cpuset shared file policy
	control
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070625141031.904935b5.pj@sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <20070625195335.21210.82618.sendpatchset@localhost>
	 <20070625141031.904935b5.pj@sgi.com>
Content-Type: text/plain
Date: Wed, 27 Jun 2007 13:33:04 -0400
Message-Id: <1182965584.4948.13.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-25 at 14:10 -0700, Paul Jackson wrote:
> Lee wrote:
> > +#ifdef CONFIG_NUMA
> 
> Hmmm ... our very first ifdef CONFIG_NUMA in kernel/cpuset.c,
> and the second ifdef ever in that file.  (And I doubt that
> the first ifdef, on CONFIG_MEMORY_HOTPLUG, is necessary.)

Yeah, I was expecting this comment.  ;-) more below...
> 
> How about we just remove these ifdef CONFIG_NUMA's, and
> let that per-cpuset 'shared_file_policy' always be present?
> It just won't do a heck of a lot on non-NUMA systems.

If my patches eventually go in, I'd agree with this.  I was trying to be
a good doobee and not add code that wasn't needed.

> 
> No sense in breaking code that happens to access that file,
> just because we're running on a system where it's useless.
> It seems better to just simply, consistently, always have
> that file present.

I guess I wouldn't expect much code to access that file other than some
cpuset setup script [maybe program] that enables shared file policy.  In
my various NUMA patch sets [shared policy, lazy/automigration, ...], I
created quite a few additional control files like "shared_file_policy".
I've written scripts to set up cpusets for testing these features.  I
usually code something like:

	[[ ! -f $cpuset/shared_file_policy ]] || echo 1 >$cpuset/...

so they don't break if the file is missing--just don't do anything.

> 
> And I don't like ifdef's in kernel/cpuset.c.  If necessary,
> put them in some header file, related to whatever piece of
> code has to shrink down to nothingness when not configured.

I understand about #ifdef's in kernel code.  I would have implemented a
number of static inline functions or macros in a header, but in some
places, I need to add a case to a switch statement.  That's harder to do
with macros and static inline functions.  I wasn't sure that a macro
that defines an additional case statement would make it past the
"readability nazis" [;-)].

My experience here has made me think that the cpuset implementation for
adding additional control files conditionally could be made more "data
driven" [like procfs?] so that I only need to add a single array-element
initialization and any supporting functions under #ifdef; plus a few
conditionally defined static in-line functions for things like
"update_task_memory_state" and such.  We'd still need some ifdefs, but
not within individual functions.

Thoughts?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
