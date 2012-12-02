Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id E18656B0044
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 09:36:41 -0500 (EST)
From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [memcg:since-3.6 493/499] include/trace/events/filemap.h:14:1: sparse: incompatible types for operation (<)
References: <50b7f3c5.kjvAZJjuJNxsqjDZ%fengguang.wu@intel.com>
Date: Sun, 02 Dec 2012 15:36:26 +0100
In-Reply-To: <50b7f3c5.kjvAZJjuJNxsqjDZ%fengguang.wu@intel.com> (kbuild test
	robot's message of "Fri, 30 Nov 2012 07:46:13 +0800")
Message-ID: <87ehj81pxx.fsf@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kbuild test robot <fengguang.wu@intel.com>

kbuild test robot <fengguang.wu@intel.com> writes:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> head:   422a0f651b5cefa1b6b3ede2e1c9e540a24a6e01
> commit: 07b81da5f80b27543ddbe3164170c64e0941a812 [493/499] mm: trace filemap add and del
>
>
> sparse warnings:
>
> + include/trace/events/filemap.h:14:1: sparse: incompatible types for operation (<)
> include/trace/events/filemap.h:14:1:    left side has type struct page *<noident>
> include/trace/events/filemap.h:14:1:    right side has type int
> include/trace/events/filemap.h:45:1: sparse: incompatible types for operation (<)
> include/trace/events/filemap.h:45:1:    left side has type struct page *<noident>
> include/trace/events/filemap.h:45:1:    right side has type int

Hi Steven, Frederic and Ingo,

I just drop this note to make you aware (as FTRACE maintainers) of the sparse
warning I received.

This sparse warning will touch all submission to the FTRACE events API AFAIK.
The node of the problem :
 - in include/linux/ftrace_event.h, we have :
   #define is_signed_type(type)	(((type)(-1)) < 0)
 - this is used by kernel/trace/trace_events.c
   #define __common_field(type, item)
   ...
     is_signed_type(type)
   ...

Here, if a trace field is a pointer (for example struct page *), we end up with
this in my case :

static int __attribute__((no_instrument_function))
ftrace_define_fields_mm_filemap_delete_from_page_cache(struct ftrace_event_call
*event_call) { struct ftrace_raw_mm_filemap_delete_from_page_cache field; int
ret; ret = trace_define_field(event_call, "struct page *", "page",
__builtin_offsetof(typeof(field),page), sizeof(field.page), (((struct page
*)(-1)) < 0), FILTER_OTHER); if (ret) return ret; ret =
trace_define_field(event_call, "unsigned long", "i_ino",
__builtin_offsetof(typeof(field),i_ino), sizeof(field.i_ino), (((unsigned
long)(-1)) < 0), FILTER_OTHER); if (ret) return ret; ret =
trace_define_field(event_call, "unsigned long", "index",
__builtin_offsetof(typeof(field),index), sizeof(field.index), (((unsigned
long)(-1)) < 0), FILTER_OTHER); if (ret) return ret; ret =
trace_define_field(event_call, "dev_t", "s_dev",
__builtin_offsetof(typeof(field),s_dev), sizeof(field.s_dev), (((dev_t)(-1)) <
0), FILTER_OTHER); if (ret) return ret;; return ret; }; ;;

And I think, (((struct page *)(-1)) < 0) gives the warning. I don't know if
"is_signed_type()" makes sense on a pointer, but I think you'll get other
reports of that kind for any new event added to trace API.

Cheers.

-- 
Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
