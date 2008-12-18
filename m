Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BD5296B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 14:58:39 -0500 (EST)
Message-ID: <494AABDB.80408@cs.columbia.edu>
Date: Thu, 18 Dec 2008 15:00:27 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>	 <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu>	 <4949B4ED.9060805@google.com>  <494A2F94.2090800@cs.columbia.edu> <1229615676.17206.518.camel@nimitz>
In-Reply-To: <1229615676.17206.518.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mike Waychison <mikew@google.com>, jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Thu, 2008-12-18 at 06:10 -0500, Oren Laadan wrote:
>>>> +    for (i = pgarr->nr_used; i--; /**/)
>>>> +        page_cache_release(pgarr->pages[i]);
>>> This is sorta hard to read (and non-intuitive).  Is it easier to do:
>>>
>>> for (i = 0; i < pgarr->nr_used; i++)
>>>     page_cache_release(pgarr->pages[i]);
>>>
>>> It shouldn't matter what order you release the pages in..
>> Was meant to avoid a dereference to 'pgarr->nr_used' in the comparison.
>> (though I doubt if the performance impact is at all visible)
> 
> That's a bit to aggressive an optimization.  You two piqued my
> curiosity, so I tried a little experiment with this .c file:
> 
> extern void bar(int i);
> 
> struct s {
>         int *array;
>         int size;
> };
> 
> extern struct s *s;
> void foo(void)
> {
>         int i;
> #ifdef OREN
>         for (i = s->size; i--; )
> #else
>         for (i = 0; i < s->size; i++)
> #endif
>                 bar(s->array[i]);
> }
> 
> for O in "" -O -O1 -O2 -O3 -Os; do
> 	gcc -DOREN $O -c f1.c -o oren.o;
> 	gcc $O -c f1.c -o mike.o;
> 	echo -n Oren:; objdump -d oren.o | grep ret;
> 	echo -n Mike:; objdump -d mike.o | grep ret;
> done

For what it's worth, the idea was to improve time... (not code length).
I changed the code anyway (in response to another comment).

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
