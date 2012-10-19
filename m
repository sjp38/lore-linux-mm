Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AB9FA6B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 01:36:25 -0400 (EDT)
Message-ID: <5080E828.20109@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 13:42:00 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2]suppress "Device nodeX does not have a release() function"
 warning
References: <507656D1.5020703@jp.fujitsu.com> <50765896.4000300@jp.fujitsu.com> <CAHGf_=rvdU+TymYZSXvx1bz4xdp43bqnyjRMGEoiBizC5rP0sQ@mail.gmail.com> <507E4F0C.9040506@cn.fujitsu.com> <CAHGf_=obXYBGg9HK6d7AyAe7rjM_NyE6icr69aH-DNOp4tB+VA@mail.gmail.com>
In-Reply-To: <CAHGf_=obXYBGg9HK6d7AyAe7rjM_NyE6icr69aH-DNOp4tB+VA@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org

At 10/17/2012 04:50 PM, KOSAKI Motohiro Wrote:
> On Wed, Oct 17, 2012 at 2:24 AM, Wen Congyang <wency@cn.fujitsu.com> wrote:
>> At 10/12/2012 06:33 AM, KOSAKI Motohiro Wrote:
>>> On Thu, Oct 11, 2012 at 1:26 AM, Yasuaki Ishimatsu
>>> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>>>> When calling unregister_node(), the function shows following message at
>>>> device_release().
>>>>
>>>> "Device 'node2' does not have a release() function, it is broken and must
>>>> be fixed."
>>>>
>>>> The reason is node's device struct does not have a release() function.
>>>>
>>>> So the patch registers node_device_release() to the device's release()
>>>> function for suppressing the warning message. Additionally, the patch adds
>>>> memset() to initialize a node struct into register_node(). Because the node
>>>> struct is part of node_devices[] array and it cannot be freed by
>>>> node_device_release(). So if system reuses the node struct, it has a garbage.
>>>>
>>>> CC: David Rientjes <rientjes@google.com>
>>>> CC: Jiang Liu <liuj97@gmail.com>
>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>>>> ---
>>>>  drivers/base/node.c |   11 +++++++++++
>>>>  1 file changed, 11 insertions(+)
>>>>
>>>> Index: linux-3.6/drivers/base/node.c
>>>> ===================================================================
>>>> --- linux-3.6.orig/drivers/base/node.c  2012-10-11 10:04:02.149758748 +0900
>>>> +++ linux-3.6/drivers/base/node.c       2012-10-11 10:20:34.111806931 +0900
>>>> @@ -252,6 +252,14 @@ static inline void hugetlb_register_node
>>>>  static inline void hugetlb_unregister_node(struct node *node) {}
>>>>  #endif
>>>>
>>>> +static void node_device_release(struct device *dev)
>>>> +{
>>>> +#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>>>> +       struct node *node_dev = to_node(dev);
>>>> +
>>>> +       flush_work(&node_dev->node_work);
>>>> +#endif
>>>> +}
>>>
>>> The patch description don't explain why this flush_work() is needed.
>>
>> If the node is onlined after it is offlined, we will clear the memory,
>> so we should flush_work() before node_dev is set to 0.
> 
> So then, it is irrelevant from warning supressness. You should make an
> another patch.
> 

OK, I will update it soon.

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
