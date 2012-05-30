Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 497BF6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 07:39:27 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4210891lbj.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 04:39:25 -0700 (PDT)
Message-ID: <4FC606E7.4090701@openvz.org>
Date: Wed, 30 May 2012 15:39:19 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com> <4FC52F17.20709@openvz.org> <20120529132658.14ab9ba3.akpm@linux-foundation.org> <4FC546B1.8050508@fold.natur.cuni.cz>
In-Reply-To: <4FC546B1.8050508@fold.natur.cuni.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Martin Mokrejs wrote:
> Andrew Morton wrote:
>> On Wed, 30 May 2012 00:18:31 +0400
>> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>>
>>> Oleg Nesterov wrote:
>>>> On 05/22, Andrew Morton wrote:
>>>>>
>>>>> Also, I have a note here that Oleg was unhappy with the patch.  Oleg
>>>>> happiness is important.  Has he cheered up yet?
>>>>
>>>> Well, yes, I do not really like this patch ;) Because I think there is
>>>> a more simple/straightforward fix, see below. In my opinion it also
>>>> makes the original code simpler.
>>>>
>>>> But. Obviously this is subjective, I can't prove my patch is "better",
>>>> and I didn't try to test it.
>>>>
>>>> So I won't argue with Konstantin who dislikes my patch, although I
>>>> would like to know the reason.
>>>
>>> I don't remember why I dislike your patch.
>>> For now I can only say ACK )
>>
>> We'll need a changelogged signed-off patch, please Oleg.  And some evidence
>> that it was tested would be nice ;)
>
> I will reboot in few hours, finally after few days ... I am running this first
> patch. I will try to test the second/alternative patch more quickly. Sorry for
> the delay.
>

easiest way trigger this bug:

#define _GNU_SOURCE
#include <unistd.h>
#include <sched.h>
#include <sys/syscall.h>
#include <sys/mman.h>

static inline int sys_clone(unsigned long flags, void *stack, int *ptid, int *ctid)
{
	return syscall(SYS_clone, flags, stack, ptid, ctid);
}

int main(int argc, char **argv)
{
	void *page;

	page = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	sys_clone(CLONE_VFORK | CLONE_VM | CLONE_CHILD_CLEARTID, NULL, NULL, page);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
