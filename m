Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 69D336B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:47:48 -0400 (EDT)
Message-ID: <50810101.1070201@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 15:28:01 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/9] memory-hotplug: flush the work for the node when
 the node is offlined
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-4-git-send-email-wency@cn.fujitsu.com> <CAHGf_=oAH+Ky9JbrMrEsd53=a1NBq1+jtr1HkBwnGm4qBZCRAw@mail.gmail.com>
In-Reply-To: <CAHGf_=oAH+Ky9JbrMrEsd53=a1NBq1+jtr1HkBwnGm4qBZCRAw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

At 10/19/2012 03:01 PM, KOSAKI Motohiro Wrote:
> On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> If the node is onlined after it is offlined, we will clear the memory
>> to store the node's information. This structure contains struct work,
>> so we should flush work before the work's information is cleared.
> 
> This explanation is incorrect. Even if you don't call memset(), you should
> call flush_work() at offline event. Because of, after offlinining, we
> shouldn't touch any node data. Alive workqueue violate this principle.

Yes, I will update the description.

> 
> And, hmmm... Wait. Usually workqueue shutdowning has two phase. 1)
> inhibit enqueue new work 2) flush work. Otherwise other cpus may
> enqueue new work after flush_work(). Where is (1)?
> 


We schedule the work only when a memory section is onlined/offlined on this
node. When we come here, all the memory on this node has been offlined,
so we won't enqueue new work to this work. I will add a comment
to descript this.

Thanks
Wen Congyang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
