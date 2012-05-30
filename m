Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 0360F6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 08:54:39 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4285716lbj.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 05:54:38 -0700 (PDT)
Message-ID: <4FC6188A.2030003@openvz.org>
Date: Wed, 30 May 2012 16:54:34 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com> <4FC52F17.20709@openvz.org> <20120529132658.14ab9ba3.akpm@linux-foundation.org> <4FC546B1.8050508@fold.natur.cuni.cz> <4FC606E7.4090701@openvz.org> <4FC60BBC.203@fold.natur.cuni.cz> <4FC61107.8050002@openvz.org>
In-Reply-To: <4FC61107.8050002@openvz.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Konstantin Khlebnikov wrote:
> Martin Mokrejs wrote:
>>
>>
>> Konstantin Khlebnikov wrote:
>>> Martin Mokrejs wrote:
>>>> Andrew Morton wrote:
>>>>> On Wed, 30 May 2012 00:18:31 +0400
>>>>> Konstantin Khlebnikov<khlebnikov@openvz.org>    wrote:
>>>>>
>>>>>> Oleg Nesterov wrote:
>>>>>>> On 05/22, Andrew Morton wrote:
>>>>>>>>
>>>>>>>> Also, I have a note here that Oleg was unhappy with the patch.  Oleg
>>>>>>>> happiness is important.  Has he cheered up yet?
>>>>>>>
>>>>>>> Well, yes, I do not really like this patch ;) Because I think there is
>>>>>>> a more simple/straightforward fix, see below. In my opinion it also
>>>>>>> makes the original code simpler.
>>>>>>>
>>>>>>> But. Obviously this is subjective, I can't prove my patch is "better",
>>>>>>> and I didn't try to test it.
>>>>>>>
>>>>>>> So I won't argue with Konstantin who dislikes my patch, although I
>>>>>>> would like to know the reason.
>>>>>>
>>>>>> I don't remember why I dislike your patch.
>>>>>> For now I can only say ACK )
>>>>>
>>>>> We'll need a changelogged signed-off patch, please Oleg.  And some evidence
>>>>> that it was tested would be nice ;)
>>>>
>>>> I will reboot in few hours, finally after few days ... I am running this first
>>>> patch. I will try to test the second/alternative patch more quickly. Sorry for
>>>> the delay.
>>>>
>>>
>>> easiest way trigger this bug:
>>>
>>> #define _GNU_SOURCE
>>> #include<unistd.h>
>>> #include<sched.h>
>>> #include<sys/syscall.h>
>>> #include<sys/mman.h>
>>>
>>> static inline int sys_clone(unsigned long flags, void *stack, int *ptid, int *ctid)
>>> {
>>>       return syscall(SYS_clone, flags, stack, ptid, ctid);
>>> }
>>>
>>> int main(int argc, char **argv)
>>> {
>>>       void *page;
>>>
>>>       page = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
>>>       sys_clone(CLONE_VFORK | CLONE_VM | CLONE_CHILD_CLEARTID, NULL, NULL, page);
>>> }
>>>
>>
>> I am getting segfaults with this.
>>
>> (gdb) where
>> #0  0x0000000000000000 in ?? ()
>> #1  0x00007f430f70a7e0 in __elf_set___libc_subfreeres_element_free_mem__ () from /lib64/libc.so.6
>> #2  0x00007f430f70a7e8 in __elf_set___libc_atexit_element__IO_cleanup__ () from /lib64/libc.so.6
>> #3  0x0000000000000001 in ?? ()
>> #4  0x0000000000000000 in ?? ()
>> (gdb)
>>
>> What number should I give it as an argument? ;-)
>
> there is no arguments.
>
> yeah it corrupts stack. I'm too lazy to write it properly =)
> but on non-patched kernel it also triggers this bug:
> [206732.025131] BUG: Bad rss-counter state mm:ffff88000d8a6c80 idx:1 val:-1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

this version works without segfaults =)

#define _GNU_SOURCE
#include <stdlib.h>
#include <sched.h>
#include <sys/mman.h>

int child(void *arg)
{
	return 0;
}

char stack[4096];

int main(int argc, char **argv)
{
	void *page;

	page = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	clone(child, stack + sizeof(stack), CLONE_VFORK | CLONE_VM | CLONE_CHILD_CLEARTID, NULL, NULL, NULL, page);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
