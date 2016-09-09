Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16FFD6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 00:06:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so25948515lfb.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 21:06:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w3si1152932wmd.40.2016.09.08.21.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 21:06:08 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8942iFk013112
	for <linux-mm@kvack.org>; Fri, 9 Sep 2016 00:06:07 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25bc2rcxs1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Sep 2016 00:06:07 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 22:06:06 -0600
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] mm, page_alloc: warn about empty nodemask
From: Li Zhong <zhong@linux.vnet.ibm.com>
In-Reply-To: <20160908162621.51ff52413559a7a6bb5a7df5@linux-foundation.org>
Date: Fri, 9 Sep 2016 12:03:47 +0800
Content-Transfer-Encoding: quoted-printable
References: <1473044391.4250.19.camel@TP420> <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz> <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com> <3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz> <1473208886.12692.2.camel@TP420> <20160908162621.51ff52413559a7a6bb5a7df5@linux-foundation.org>
Message-Id: <D1029A5D-C180-440C-8B14-A6C9E17CDB06@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>


> On Sep 9, 2016, at 07:26, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> On Wed, 07 Sep 2016 08:41:26 +0800 Li Zhong <zhong@linux.vnet.ibm.com> =
wrote:
>=20
>> Warn about allocating with an empty nodemask, it would be easier to
>> understand than oom messages. The check is added in the slow path.
>>=20
>> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
>> ---=20
>> mm/page_alloc.c | 6 ++++++
>> 1 file changed, 6 insertions(+)
>>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a2214c6..d624ff3 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3448,6 +3448,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, =
unsigned int order,
>> 	if (page)
>> 		goto got_pg;
>>=20
>> +	if (ac->nodemask && nodes_empty(*ac->nodemask)) {
>> +		pr_warn("nodemask is empty\n");
>> +		gfp_mask &=3D ~__GFP_NOWARN;
>> +		goto nopage;
>> +	}
>> +
>=20
> Wouldn't it be better to do
>=20
> 	if (WARN_ON(ac->nodemask && nodes_empty(*ac->nodemask)) {
> 		...
>=20
> so we can identify the misbehaving call site?

I think with __GFP_NOWARN cleared, we could know the call site from =
warn_alloc_failed().=20
And the message =E2=80=9Cnodemask is empty=E2=80=9D makes the error =
obvious without going to the source.=20

Thanks, Zhong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
