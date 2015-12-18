Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id F31946B0003
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 21:12:49 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id e126so75551342ioa.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 18:12:49 -0800 (PST)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id qm5si7256664igb.59.2015.12.17.18.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 18:12:49 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 42E6CAC0177
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:12:39 +0900 (JST)
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
 <566A9AE1.7020001@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
 <56722258.6030800@huawei.com> <567223A7.9090407@jp.fujitsu.com>
 <56723E8B.8050201@huawei.com> <567241BE.5030806@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F39F882E8@ORSMSX114.amr.corp.intel.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56736B7D.3040709@jp.fujitsu.com>
Date: Fri, 18 Dec 2015 11:12:13 +0900
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F882E8@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/18 3:43, Luck, Tony wrote:
>>>> As Tony requested, we may need a knob to stop a fallback in "movable->normal", later.
>>>>
>>>
>>> If the mirrored memory is small and the other is large,
>>> I think we can both enable "non-mirrored -> normal" and "normal -> non-mirrored".
>>
>> Size of mirrored memory can be configured by software(EFI var).
>> So, having both is just overkill and normal->non-mirroed fallback is meaningless considering
>> what the feature want to guarantee.
>
> In the original removable usage we wanted to guarantee that Linux did not allocate any
> kernel objects in removable memory - because that would prevent later removal of that
> memory.
>
> Mirror case is the same - we don't want to allocate kernel structures in non-mirrored memory
> because an uncorrectable error in one of them would crash the system.
>
> But I think some users might like some flexibility here.  If the system doesn't have enough
> memory for the kernel (non-movable or mirrored), then it seems odd to end up crashing
> the system at the point of memory exhaustion (a likely result ... the kernel can try to reclaim
> some pages from SLAB, but that might only return a few pages, if the shortage continues
> the system will perform poorly and eventually fail).
>
> The whole point of removable memory or mirrored memory is to provide better availability.
>
> I'd vote for a mode where running out of memory for kernel results in a
>
>     warn_on_once("Ran out of mirrored/non-removable memory for kernel - now allocating from all zones\n")
>
> because I think most people would like the system to stay up rather than worry about some future problem that may never happen.

Hmm...like this ?
       sysctl.vm.fallback_mirror_memory = 0  // never fallback  # default.
       sysctl.vm.fallback_mirror_memory = 1  // the user memory may be allocated from mirrored zone.
       sysctl.vm.fallback_mirror_memory = 2  // usually kernel allocates memory from mirrored zone before OOM.
       sysctl.vm.fallback_mirror_memory = 3  // 1+2

However I believe my customer's choice is always 0, above implementation can be done in a clean way.
(adding a flag to zones (mirrored or not) and controlling fallback zonelist walk.)

BTW, we need this Taku's patch to make a progress. I think other devs should be done in another
development cycle. What does he need to get your Acks ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
