Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 20FC46B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 02:55:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 16CFF3EE0BC
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 15:55:07 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF61445DEBC
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 15:55:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B5AAF45DEBE
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 15:55:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0A5B1DB803B
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 15:55:06 +0900 (JST)
Received: from g01jpexchkw06.g01.fujitsu.local (g01jpexchkw06.g01.fujitsu.local [10.0.194.45])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29AE71DB8040
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 15:55:06 +0900 (JST)
Message-ID: <50693E30.3010006@jp.fujitsu.com>
Date: Mon, 1 Oct 2012 15:54:40 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com> <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com> <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com> <5065740A.2000502@jp.fujitsu.com> <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com>
In-Reply-To: <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/09/29 7:19, KOSAKI Motohiro wrote:
>>>> I don't understand it. How can we get rid of the warning?
>>>
>>> See cpu_device_release() for example.
>>
>> If we implement a function like cpu_device_release(), the warning
>> disappears. But the comment says in the function "Never copy this way...".
>> So I think it is illegal way.
>
> What does "illegal" mean?

The "illegal" means the code should not be mimicked.

> You still haven't explain any benefit of your code. If there is zero
> benefit, just kill it.
> I believe everybody think so.
>
> Again, Which benefit do you have?

The patch has a benefit to delets a warning message.

>
>>>>> Why do we need this node_device_release() implementation?
>>>>
>>>> I think that this is a manner of releasing object related kobject.
>>>
>>> No.  Usually we never call memset() from release callback.
>>
>> What we want to release is a part of array, not a pointer.
>> Therefore, there is only this way instead of kfree().
>
> Why? Before your patch, we don't have memset() and did work it.

If we does not apply the patch, a warning message is shown.
So I think it did not work well.

> I can't understand what mean "only way".

For deleting a warning message, I created a node_device_release().
In the manner of releasing kobject, the function frees a object related
to the kobject. So most functions calls kfree() for releasing it.
In node_device_release(), we need to free a node struct. If the node
struct is pointer, I can free it by kfree. But the node struct is a part
of node_devices[] array. I cannot free it. So I filled the node struct
with 0.

But you think it is not good. Do you have a good solution?

Thanks,
Yasuaki Ishimatsu

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
