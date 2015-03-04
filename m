Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 05DBE6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 23:13:52 -0500 (EST)
Received: by padet14 with SMTP id et14so33432513pad.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 20:13:51 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id sp8si3425306pac.126.2015.03.03.20.13.50
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 20:13:51 -0800 (PST)
Message-ID: <54F68270.5000203@cn.fujitsu.com>
Date: Wed, 4 Mar 2015 11:56:32 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F67376.8050001@huawei.com>
In-Reply-To: <54F67376.8050001@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Li Zefan <lizefan@huawei.com>

Hi Xishi,
On 03/04/2015 10:52 AM, Xishi Qiu wrote:

> On 2015/3/4 10:22, Xishi Qiu wrote:
>=20
>> On 2015/3/3 18:20, Gu Zheng wrote:
>>
>>> Hi Xishi,
>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>
>>>> When hot-remove a numa node, we will clear pgdat,
>>>> but is memset 0 safe in try_offline_node()?
>>>
>>> It is not safe here. In fact, this is a temporary solution here.
>>> As you know, pgdat is accessed lock-less now, so protection
>>> mechanism (RCU=EF=BC=9F) is needed to make it completely safe here,
>>> but it seems a bit over-kill.
>>>
>=20
> Hi Gu,
>=20
> Can we just remove "memset(pgdat, 0, sizeof(*pgdat));" ?
> I find this will be fine in the stress test except the warning=20
> when hot-add memory.

As you see, it will trigger the warning in free_area_init_node().
Could you try the following patch? It will reset the pgdat before reuse it.

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1778628..0717649 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1092,6 +1092,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64=
 start)
                        return NULL;
=20
                arch_refresh_nodedata(nid, pgdat);
+       } else {
+               /* Reset the pgdat to reuse */
+               memset(pgdat, 0, sizeof(*pgdat));
        }
=20
        /* we can use NODE_DATA(nid) from here */
@@ -2021,15 +2024,6 @@ void try_offline_node(int nid)
=20
        /* notify that the node is down */
        call_node_notify(NODE_DOWN, (void *)(long)nid);
-
-       /*
-        * Since there is no way to guarentee the address of pgdat/zone is =
not
-        * on stack of any kernel threads or used by other kernel objects
-        * without reference counting or other symchronizing method, do not
-        * reset node_data and free pgdat here. Just reset it to 0 and reus=
e
-        * the memory when the node is online again.
-        */
-       memset(pgdat, 0, sizeof(*pgdat));
 }
 EXPORT_SYMBOL(try_offline_node);
=20

>=20
> Thanks,
> Xishi Qiu
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
