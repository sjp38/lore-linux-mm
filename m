Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D57736B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:13:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so28388961lfs.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 19:13:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m10si28117571wja.285.2016.09.20.19.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 19:13:46 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8L2CmWi121127
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:13:45 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25jmr1mwhr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:13:45 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Tue, 20 Sep 2016 20:13:44 -0600
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
From: Li Zhong <zhong@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
Date: Wed, 21 Sep 2016 10:11:29 +0800
Content-Transfer-Encoding: quoted-printable
References: <1473044391.4250.19.camel@TP420> <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz> <20160912091811.GE14524@dhcp22.suse.cz> <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz> <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
Message-Id: <078BDBDC-6274-4D06-917A-50B0E1112A66@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>


> On Sep 21, 2016, at 05:53, David Rientjes <rientjes@google.com> wrote:
>=20
> On Tue, 20 Sep 2016, Vlastimil Babka wrote:
>=20
>> On 09/12/2016 11:18 AM, Michal Hocko wrote:
>>> On Mon 05-09-16 16:18:29, Vlastimil Babka wrote:
>>>=20
>>>> Also OOM is skipped for __GFP_THISNODE
>>>> allocations, so we might also consider the same for =
nodemask-constrained
>>>> allocations?
>>>>=20
>>>>> The patch checks whether it is the last node on the system, and if =
it
>>>> is, then
>>>>> don't clear the nid in the nodemask.
>>>>=20
>>>> I'd rather see the allocation not OOM, and rely on the fallback in
>>>> new_node_page() that doesn't have nodemask. But I suspect it might =
also
>>>> make
>>>> sense to treat empty nodemask as something unexpected and put some =
WARN_ON
>>>> (instead of OOM) in the allocator.
>>>=20
>>> To be honest I am really not all that happy about 394e31d2ceb4
>>> ("mem-hotplug: alloc new page from a nearest neighbor node when
>>> mem-offline") and find it a bit fishy. I would rather re-iterate =
that
>>> patch rather than build new hacks on top.
>>=20
>> OK, IIRC I suggested the main idea of clearing the current node from =
nodemask
>> and relying on nodelist to get us the other nodes sorted by their =
distance.
>> Which I thought was an easy way to get to the theoretically optimal =
result.
>> How would you rewrite it then? (but note that the fix is already =
mainline).
>>=20
>=20
> This is a mess.  Commit 9bb627be47a5 ("mem-hotplug: don't clear the =
only=20
> node in new_node_page()") is wrong because it's clearing nid when the =
next=20
> node in node_online_map doesn't match.  node_online_map is wrong =
because=20
> it includes memoryless nodes.  (Nodes with closest NUMA distance also =
do=20
> not need to have adjacent node ids.)

Thanks for pointing out that, so it is still possible that we are =
allocating from one
or more memoryless nodes, which is the same as from an empty mask.=20

I will try to fix it as you suggested below, test and send it soon.=20
=20
>=20
> This is all protected by mem_hotplug_begin() and the zonelists will be=20=

> stable.  The solution is to rewrite new_node_page() to work correctly. =
=20
> Use node_states[N_MEMORY] as mask, clear page_to_nid(page).  If mask =
is=20
> not empty, do
>=20
> __alloc_pages_nodemask(gfp_mask, 0,
> node_zonelist(page_to_nid(page), gfp_mask), &mask)=20
>=20
> and fallback to alloc_page(gfp_mask), which should also be used if the=20=

> mask is empty -- do not try to allocate memory from the empty set of=20=

> nodes.
>=20
> mm-page_alloc-warn-about-empty-nodemask.patch is a rather ridiculous=20=

> warning to need.  The largest user of a page allocator nodemask is=20
> mempolicies which makes sure it doesn't pass an empty set.  If it's =
really=20
> required, it should at least be unlikely() since the vast majority of=20=

> callers will have ac->nodemask =3D=3D NULL.
>=20
OK, I=E2=80=99ll send a new version adding unlikely().

Thanks, Zhong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
