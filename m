Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BEBCC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 09:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33E1820880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 09:39:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33E1820880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BE766B0008; Mon,  8 Apr 2019 05:39:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9468E6B000A; Mon,  8 Apr 2019 05:39:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C1A26B000C; Mon,  8 Apr 2019 05:39:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51DF26B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 05:39:04 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id s65so9386913ywf.10
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 02:39:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=xWD03Zqt1SJ9xAy4s328/gi1lbz9D0FCaf2vPXGYinI=;
        b=TyVxyvFBpR1yfZThw/hh/CvIgAMbTljiNI14WPDPczHRwDsgr34mcXTyLnzPk88smB
         FgQNC04wAlgFru3OseGqsSrJGyzfWKPA0PCcisU5x9E1j99NNNzlZ1vOpMetal6wWHZe
         GpRIgrNKNeV/uNgCV95ri/aIAMhikyr/L7dyOiBnXFmYHl3yQp/IHAJFDiWLvqUtMpbG
         /aWdhf0MgNg0E8rP9NSwGskoPFJu0gzWIheBqDoiOKwmK+DVCQw0hqLmNtcUG99aOF1u
         +ATG8Sj1MIVIYRhdZXdN2uIrAAWlmFqz+IzarQe1L4BF+bfgrddSG6Xt3BU84nGtIwDf
         R+dA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXA9wi8ksWH0li4UHCNn+w7BzM15B7wJDrNQugKFAuCAn3HW/cL
	pTh1DAr5Irw+KeuJAKQY3SgpjZUCY/HtbVsqmWQe5Lve8mO8cxQKGqtg3SQkabZN30ocIVeNQ66
	30gftgmJHWBISc+avvhmOEsSy9dTAS+SkusjIb1Alj662D/H8V1WZsj//KuEEk51xXA==
X-Received: by 2002:a25:1144:: with SMTP id 65mr23749313ybr.142.1554716344055;
        Mon, 08 Apr 2019 02:39:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwu5Zut2WjCMQAmvy7m18fmuFWhTAmkawAMxFIN7Wd2/VHWn1smAYWH9NCEvr6Pym17M8Lf
X-Received: by 2002:a25:1144:: with SMTP id 65mr23749285ybr.142.1554716343416;
        Mon, 08 Apr 2019 02:39:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554716343; cv=none;
        d=google.com; s=arc-20160816;
        b=ThzTF0QOcZJWI0JosCEBk+aNLIDH/uzNtJvKIB+/qzHBhAFiM6/3qaDjRAbctuicKY
         xJv8HdgtcFba7izMOqXy3vvgArT5vIe05JY2/rmXNU4agLe3/yu6yEBnVwbfwP2KMSR9
         bPuXczJOAUwDOtOgKEO6fywXmcPxgz22p6zzUJl9t2pvQ5Ty2ODd4Oo7c+DOn1j05OS6
         DCNJM3mwfHA/u3jqAd12RZ9+PjZ4pMQJGdBdzgnfQJnNdNUh+9137fziC/LC5vUIzDuI
         d6+VEIhU1eo8HfyKHJqYcEF76NiogAP2Xn4r//x6My8N64i/pkGQ4fYBMGSJ7Lz9KSso
         1rBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=xWD03Zqt1SJ9xAy4s328/gi1lbz9D0FCaf2vPXGYinI=;
        b=0FpPB8W0XteeHwCiScWwJTlG2MLX/Jmul48lZP1XtEs1NvInWMZ9ajX8cmCojlmAHs
         VtHzr3yNhvl0usH7uyTjNwoNHSz8Vjlu8Noae0p4a8J1aexyv5dAp7mZPQrecF4WMkrN
         bVcBrcnlh1F7cwNMg0fH83KKZEtsRYTwMMCJdRQ/f7jVhj7HE8b4u/+/DGUAnLLuSpVj
         raUGogN+GRzt5jF31HPdNaChKpAksbOoFgH3v1RLD3Jks/kAMvMNS8d5kgZeAsR35sWU
         bVoAMSVatWEhzG1MIVnvHja88GsUOoBXsEX7eoEVnBJqZqq0HNbtxd+WxpStS5fzE1Y4
         p4mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 207si18247466ywy.172.2019.04.08.02.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 02:39:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x389U8h0105126
	for <linux-mm@kvack.org>; Mon, 8 Apr 2019 05:39:03 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rr2uv2t0h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 Apr 2019 05:39:02 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 8 Apr 2019 10:39:00 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 8 Apr 2019 10:38:57 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x389cuWp56688680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 8 Apr 2019 09:38:56 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ACFBD42049;
	Mon,  8 Apr 2019 09:38:56 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1190842041;
	Mon,  8 Apr 2019 09:38:55 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.209])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon,  8 Apr 2019 09:38:54 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <zwisler@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2] fs/dax: deposit pagetable even when installing zero page
In-Reply-To: <CAPcyv4irZP2F1acuco7UVbvTARzn5SXvCAWstFYtP7ygLRSXTg@mail.gmail.com>
References: <20190309120721.21416-1-aneesh.kumar@linux.ibm.com> <8736nrnzxm.fsf@linux.ibm.com> <20190313095834.GF32521@quack2.suse.cz> <CAPcyv4irZP2F1acuco7UVbvTARzn5SXvCAWstFYtP7ygLRSXTg@mail.gmail.com>
Date: Mon, 08 Apr 2019 15:08:53 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19040809-0020-0000-0000-0000032D6DD8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040809-0021-0000-0000-0000217F8DDF
Message-Id: <87r2acn8eq.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-08_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904080088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


 Hi Dan,

Dan Williams <dan.j.williams@intel.com> writes:

> On Wed, Mar 13, 2019 at 2:58 AM Jan Kara <jack@suse.cz> wrote:
>>
>> On Wed 13-03-19 10:17:17, Aneesh Kumar K.V wrote:
>> >
>> > Hi Dan/Andrew/Jan,
>> >
>> > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>> >
>> > > Architectures like ppc64 use the deposited page table to store hardware
>> > > page table slot information. Make sure we deposit a page table when
>> > > using zero page at the pmd level for hash.
>> > >
>> > > Without this we hit
>> > >
>> > > Unable to handle kernel paging request for data at address 0x00000000
>> > > Faulting instruction address: 0xc000000000082a74
>> > > Oops: Kernel access of bad area, sig: 11 [#1]
>> > > ....
>> > >
>> > > NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
>> > > LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
>> > > Call Trace:
>> > >  hash_page_mm+0x43c/0x740
>> > >  do_hash_page+0x2c/0x3c
>> > >  copy_from_iter_flushcache+0xa4/0x4a0
>> > >  pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
>> > >  dax_copy_from_iter+0x40/0x70
>> > >  dax_iomap_actor+0x134/0x360
>> > >  iomap_apply+0xfc/0x1b0
>> > >  dax_iomap_rw+0xac/0x130
>> > >  ext4_file_write_iter+0x254/0x460 [ext4]
>> > >  __vfs_write+0x120/0x1e0
>> > >  vfs_write+0xd8/0x220
>> > >  SyS_write+0x6c/0x110
>> > >  system_call+0x3c/0x130
>> > >
>> > > Fixes: b5beae5e224f ("powerpc/pseries: Add driver for PAPR SCM regions")
>> > > Reviewed-by: Jan Kara <jack@suse.cz>
>> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> >
>> > Any suggestion on which tree this patch should got to? Also since this
>> > fix a kernel crash, we may want to get this to 5.1?
>>
>> I think this should go through Dan's tree...
>
> I'll merge this and let it soak in -next for a week and then submit for 5.1-rc2.

Any update on this? Did you get to merge this?

-aneesh

