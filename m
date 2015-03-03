Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2E36B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 05:37:39 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so23843330pdb.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 02:37:38 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id fn7si392415pdb.157.2015.03.03.02.37.37
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 02:37:38 -0800 (PST)
Message-ID: <54F58AE3.50101@cn.fujitsu.com>
Date: Tue, 3 Mar 2015 18:20:19 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com>
In-Reply-To: <54F52ACF.4030103@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>

Hi Xishi,
On 03/03/2015 11:30 AM, Xishi Qiu wrote:

> When hot-remove a numa node, we will clear pgdat,
> but is memset 0 safe in try_offline_node()?

It is not safe here. In fact, this is a temporary solution here.
As you know, pgdat is accessed lock-less now, so protection
mechanism (RCU=EF=BC=9F) is needed to make it completely safe here,
but it seems a bit over-kill.

>=20
> process A:			offline node XX:
> for_each_populated_zone()
> find online node XX
> cond_resched()
> 				offline cpu and memory, then try_offline_node()
> 				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
> access node XX's pgdat
> NULL pointer access error

It's possible, but I did not meet this condition, did you?

Regards,
Gu

>=20
> Thanks,
> Xishi Qiu
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
