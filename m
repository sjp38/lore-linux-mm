Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5C00C3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E792085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 07:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E792085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B9736B0008; Mon, 19 Aug 2019 03:12:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 343DF6B000A; Mon, 19 Aug 2019 03:12:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E2EA6B000E; Mon, 19 Aug 2019 03:12:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id E96266B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:12:03 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 940CB52CB
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:12:03 +0000 (UTC)
X-FDA: 75838308126.30.crib86_6937d6cc25f32
X-HE-Tag: crib86_6937d6cc25f32
X-Filterd-Recvd-Size: 8537
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:12:02 +0000 (UTC)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7J779xY119696
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:12:01 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ufnsmu6c3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 03:12:01 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 19 Aug 2019 08:11:57 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 19 Aug 2019 08:11:55 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7J7Bs4049283074
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 19 Aug 2019 07:11:55 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE3784204C;
	Mon, 19 Aug 2019 07:11:54 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D2E6F42042;
	Mon, 19 Aug 2019 07:11:53 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.35.64])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 19 Aug 2019 07:11:53 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [PATCH v5 3/4] mm/nvdimm: Use correct #defines instead of open coding
In-Reply-To: <CAPcyv4hc_-oGMp6jGVknnYs+rmj4W1A_gFCbmAX2LFw0hsfL5g@mail.gmail.com>
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com> <20190809074520.27115-4-aneesh.kumar@linux.ibm.com> <CAPcyv4hc_-oGMp6jGVknnYs+rmj4W1A_gFCbmAX2LFw0hsfL5g@mail.gmail.com>
Date: Mon, 19 Aug 2019 12:41:52 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19081907-0012-0000-0000-00000340421B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081907-0013-0000-0000-0000217A60CE
Message-Id: <87v9ut1vev.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190082
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> Use PAGE_SIZE instead of SZ_4K and sizeof(struct page) instead of 64.
>> If we have a kernel built with different struct page size the previous
>> patch should handle marking the namespace disabled.
>
> Each of these changes carry independent non-overlapping regression
> risk, so lets split them into separate patches. Others might
>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>  drivers/nvdimm/label.c          | 2 +-
>>  drivers/nvdimm/namespace_devs.c | 6 +++---
>>  drivers/nvdimm/pfn_devs.c       | 3 ++-
>>  drivers/nvdimm/region_devs.c    | 8 ++++----
>>  4 files changed, 10 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
>> index 73e197babc2f..7ee037063be7 100644
>> --- a/drivers/nvdimm/label.c
>> +++ b/drivers/nvdimm/label.c
>> @@ -355,7 +355,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
>>
>>         /* check that DPA allocations are page aligned */
>>         if ((__le64_to_cpu(nd_label->dpa)
>> -                               | __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
>> +                               | __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)
>
> The UEFI label specification has no concept of PAGE_SIZE, so this
> check is a pure Linux-ism. There's no strict requirement why
> slot_valid() needs to check for page alignment and it would seem to
> actively hurt cross-page-size compatibility, so let's delete the check
> and rely on checksum validation.


Will do a separate patch to drop that check.

>
>>                 return false;
>>
>>         /* check checksum */
>> diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
>> index a16e52251a30..a9c76df12cb9 100644
>> --- a/drivers/nvdimm/namespace_devs.c
>> +++ b/drivers/nvdimm/namespace_devs.c
>> @@ -1006,10 +1006,10 @@ static ssize_t __size_store(struct device *dev, unsigned long long val)
>>                 return -ENXIO;
>>         }
>>
>> -       div_u64_rem(val, SZ_4K * nd_region->ndr_mappings, &remainder);
>> +       div_u64_rem(val, PAGE_SIZE * nd_region->ndr_mappings, &remainder);
>>         if (remainder) {
>> -               dev_dbg(dev, "%llu is not %dK aligned\n", val,
>> -                               (SZ_4K * nd_region->ndr_mappings) / SZ_1K);
>> +               dev_dbg(dev, "%llu is not %ldK aligned\n", val,
>> +                               (PAGE_SIZE * nd_region->ndr_mappings) / SZ_1K);
>>                 return -EINVAL;
>
> Yes, looks good, but this deserves its own independent patch.
>
>>         }
>>
>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
>> index 37e96811c2fc..c1d9be609322 100644
>> --- a/drivers/nvdimm/pfn_devs.c
>> +++ b/drivers/nvdimm/pfn_devs.c
>> @@ -725,7 +725,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>                  * when populating the vmemmap. This *should* be equal to
>>                  * PMD_SIZE for most architectures.
>>                  */
>> -               offset = ALIGN(start + SZ_8K + 64 * npfns, align) - start;
>> +               offset = ALIGN(start + SZ_8K + sizeof(struct page) * npfns,
>
> I'd prefer if this was not dynamic and was instead set to the maximum
> size of 'struct page' across all archs just to enhance cross-arch
> compatibility. I think that answer is '64'.


That still doesn't take care of the case where we add new elements to
struct page later. If we have struct page size changing across
architectures, we should still be ok as long as new size is less than what is
stored in pfn superblock? I understand the desire to keep it
non-dynamic. But we also need to make sure we don't reserve less space
when creating a new namespace on a config that got struct page size >
64? 


>> +                              align) - start;
>>         } else if (nd_pfn->mode == PFN_MODE_RAM)
>>                 offset = ALIGN(start + SZ_8K, align) - start;
>>         else
>> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
>> index af30cbe7a8ea..20e265a534f8 100644
>> --- a/drivers/nvdimm/region_devs.c
>> +++ b/drivers/nvdimm/region_devs.c
>> @@ -992,10 +992,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
>>                 struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
>>                 struct nvdimm *nvdimm = mapping->nvdimm;
>>
>> -               if ((mapping->start | mapping->size) % SZ_4K) {
>> -                       dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
>> -                                       caller, dev_name(&nvdimm->dev), i);
>> -
>> +               if ((mapping->start | mapping->size) % PAGE_SIZE) {
>> +                       dev_err(&nvdimm_bus->dev,
>> +                               "%s: %s mapping%d is not %ld aligned\n",
>> +                               caller, dev_name(&nvdimm->dev), i, PAGE_SIZE);
>>                         return NULL;
>>                 }
>>
>> --
>> 2.21.0
>>


