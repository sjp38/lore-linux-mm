Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FAF3C3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFA8C20874
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:05:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFA8C20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 741986B000C; Mon, 19 Aug 2019 03:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1E56B000D; Mon, 19 Aug 2019 03:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF296B000E; Mon, 19 Aug 2019 03:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 37A736B000C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:05:40 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CAAC02C8B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:05:39 +0000 (UTC)
X-FDA: 75838291998.12.verse94_3165c45508752
X-HE-Tag: verse94_3165c45508752
X-Filterd-Recvd-Size: 7369
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:05:39 +0000 (UTC)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7J72U3m142599
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:05:38 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ufn6ec62j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:05:38 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 19 Aug 2019 08:05:36 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 19 Aug 2019 08:05:33 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7J75WWR13107280
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 19 Aug 2019 07:05:32 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 95AFD52054;
	Mon, 19 Aug 2019 07:05:32 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.35.64])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id B12A352051;
	Mon, 19 Aug 2019 07:05:31 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [PATCH v5 1/4] nvdimm: Consider probe return -EOPNOTSUPP as success
In-Reply-To: <CAPcyv4hxo4HvtqZ-B6JG5iATo_vEAKPzO5EU5Lugs2_edEbW7Q@mail.gmail.com>
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com> <20190809074520.27115-2-aneesh.kumar@linux.ibm.com> <CAPcyv4jmxKPkTh0_Bbu2tRXm4vcBHonZJ6UcKrOBnPGCG2_i1A@mail.gmail.com> <CAPcyv4hxo4HvtqZ-B6JG5iATo_vEAKPzO5EU5Lugs2_edEbW7Q@mail.gmail.com>
Date: Mon, 19 Aug 2019 12:35:30 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19081907-0008-0000-0000-0000030A9AB1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081907-0009-0000-0000-00004A28BCAB
Message-Id: <87y2zp1vph.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190081
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Tue, Aug 13, 2019 at 9:22 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> Hi Aneesh, logic looks correct but there are some cleanups I'd like to
>> see and a lead-in patch that I attached.
>>
>> I've started prefixing nvdimm patches with:
>>
>>     libnvdimm/$component:
>>
>> ...since this patch mostly impacts the pmem driver lets prefix it
>> "libnvdimm/pmem: "
>>
>> On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
>> <aneesh.kumar@linux.ibm.com> wrote:
>> >
>> > This patch add -EOPNOTSUPP as return from probe callback to
>>
>> s/This patch add/Add/
>>
>> No need to say "this patch" it's obviously a patch.
>>
>> > indicate we were not able to initialize a namespace due to pfn superblock
>> > feature/version mismatch. We want to consider this a probe success so that
>> > we can create new namesapce seed and there by avoid marking the failed
>> > namespace as the seed namespace.
>>
>> Please replace usage of "we" with the exact agent involved as which
>> "we" is being referred to gets confusing for the reader.
>>
>> i.e. "indicate that the pmem driver was not..." "The nvdimm core wants
>> to consider this...".
>>
>> >
>> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> > ---
>> >  drivers/nvdimm/bus.c  |  2 +-
>> >  drivers/nvdimm/pmem.c | 26 ++++++++++++++++++++++----
>> >  2 files changed, 23 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
>> > index 798c5c4aea9c..16c35e6446a7 100644
>> > --- a/drivers/nvdimm/bus.c
>> > +++ b/drivers/nvdimm/bus.c
>> > @@ -95,7 +95,7 @@ static int nvdimm_bus_probe(struct device *dev)
>> >         rc = nd_drv->probe(dev);
>> >         debug_nvdimm_unlock(dev);
>> >
>> > -       if (rc == 0)
>> > +       if (rc == 0 || rc == -EOPNOTSUPP)
>> >                 nd_region_probe_success(nvdimm_bus, dev);
>>
>> This now makes the nd_region_probe_success() helper obviously misnamed
>> since it now wants to take actions on non-probe success. I attached a
>> lead-in cleanup that you can pull into your series that renames that
>> routine to nd_region_advance_seeds().
>>
>> When you rebase this needs a comment about why EOPNOTSUPP has special handling.
>>
>> >         else
>> >                 nd_region_disable(nvdimm_bus, dev);
>> > diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
>> > index 4c121dd03dd9..3f498881dd28 100644
>> > --- a/drivers/nvdimm/pmem.c
>> > +++ b/drivers/nvdimm/pmem.c
>> > @@ -490,6 +490,7 @@ static int pmem_attach_disk(struct device *dev,
>> >
>> >  static int nd_pmem_probe(struct device *dev)
>> >  {
>> > +       int ret;
>> >         struct nd_namespace_common *ndns;
>> >
>> >         ndns = nvdimm_namespace_common_probe(dev);
>> > @@ -505,12 +506,29 @@ static int nd_pmem_probe(struct device *dev)
>> >         if (is_nd_pfn(dev))
>> >                 return pmem_attach_disk(dev, ndns);
>> >
>> > -       /* if we find a valid info-block we'll come back as that personality */
>> > -       if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
>> > -                       || nd_dax_probe(dev, ndns) == 0)
>>
>> Similar need for an updated comment here to explain the special
>> translation of error codes.
>>
>> > +       ret = nd_btt_probe(dev, ndns);
>> > +       if (ret == 0)
>> >                 return -ENXIO;
>> > +       else if (ret == -EOPNOTSUPP)
>>
>> Are there cases where the btt driver needs to return EOPNOTSUPP? I'd
>> otherwise like to keep this special casing constrained to the pfn /
>> dax info block cases.
>
> In fact I think EOPNOTSUPP is only something that the device-dax case
> would be concerned with because that's the only interface that
> attempts to guarantee a given mapping granularity.

We need to do similar error handling w.r.t fsdax when the pfn superblock
indicates different PAGE_SIZE and struct page size? I don't think btt
needs to support EOPNOTSUPP. But we can keep it for consistency?

-aneesh


