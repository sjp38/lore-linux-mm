Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9D1EE6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 08:35:50 -0400 (EDT)
Message-ID: <4DE8D50F.1090406@redhat.com>
Date: Fri, 03 Jun 2011 14:35:27 +0200
From: Igor Mammedov <imammedo@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>	<20110601123913.GC4266@tiehlicka.suse.cz>	<4DE6399C.8070802@redhat.com>	<20110601134149.GD4266@tiehlicka.suse.cz>	<4DE64F0C.3050203@redhat.com>	<20110601152039.GG4266@tiehlicka.suse.cz>	<4DE66BEB.7040502@redhat.com> <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
In-Reply-To: <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

On 06/02/2011 01:10 AM, Hiroyuki Kamezawa wrote:
>> pc = list_entry(list->prev, struct page_cgroup, lru);
> Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
> before completion of
> create() is not populated to userland and you never be able to rmdir()
> it because you can't
> find it.
>
>
>   >26:   e8 7d 12 30 00          call   0x3012a8
>   >2b:*  8b 73 08                mov    0x8(%ebx),%esi<-- trapping
> instruction
>   >2e:   8b 7c 24 24             mov    0x24(%esp),%edi
>   >32:   8b 07                   mov    (%edi),%eax
>
> Hm, what is the call 0x3012a8 ?
>
                 pc = list_entry(list->prev, struct page_cgroup, lru);
                 if (busy == pc) {
                         list_move(&pc->lru, list);
                         busy = 0;
                         spin_unlock_irqrestore(&zone->lru_lock, flags);
                         continue;
                 }
                 spin_unlock_irqrestore(&zone->lru_lock, flags); <---- 
is  call 0x3012a8
                 ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);

and  mov 0x8(%ebx),%esi
is dereferencing of 'pc' in inlined mem_cgroup_move_parent

I've looked at vmcore once more and indeed there isn't any parallel task
that touches cgroups code path.
Will investigate if it is xen to blame for incorrect data in place.

Thanks very much for your opinion.
> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
