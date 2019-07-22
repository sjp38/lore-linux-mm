Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B088BC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:16:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73C0521955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:16:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73C0521955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5068E0007; Mon, 22 Jul 2019 12:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29BA98E0001; Mon, 22 Jul 2019 12:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18B2F8E0007; Mon, 22 Jul 2019 12:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8E0F8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:16:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so24153092pfz.10
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=BZh+IhZTMCUUJLzFYWYUuGbrVYqcJiLvSH+0Yd6W0rc=;
        b=ouGwBNTy5Wqyt4zkkcNiiUpH5H7zkssTkaCDMpi9n7flsR3xnnYU4HhjoO6y6dujYb
         eyIETDSEVE1AU8AJoJq6UOHlYdXa7qHPQUbpo3eGT0rLYvmTwzo1imTLr8+zHilfScwj
         XGxKMcQNdQr4AD1T9wuw1c2kRAuL3xyuV4uzvSII7L+clAQQ5KjmoxT7KNvofIpe+Ok3
         06EdoJIhyUKg3k7ArZymIhgMgadHVsFrB5M4YYvOCyu4N0r5isuPbx9XgyPlmFrng5au
         8TdyCF+roQel6BE/nS0rP84kwPDsynBOPUqjm+pYQkbmlcfJmrzZZK0P2ifU0pV8C2Cr
         g+eg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUB5svAYih8Qth3sF1w7Qq5YDsVj6cN6icKUUu2f1QmwU6Th1Dz
	BaHbqFiLeHizsxo8VJdnszdN+f7z65pjlrUQPI32V7+sO4lPw9AO8J/J0JQi4ARKhhhoR9qYhyx
	RMTG6zB/Qm81oEwti8NnVy9Psf4xZZzwor2gj7/HnF452K0VBEmKWkFAGGLAalgs=
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr76417634plp.109.1563812165553;
        Mon, 22 Jul 2019 09:16:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytQjJ2iuy5Ub3BkSdHo1kauY2I0zBHxK8nsm2qLtTUcTcaaGraU5F9UL2fAU3x/pugQqV+
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr76417598plp.109.1563812165037;
        Mon, 22 Jul 2019 09:16:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563812165; cv=none;
        d=google.com; s=arc-20160816;
        b=IOUr+KSL20psRh5mRXk+R6ZD1qmslTRVUxx6UKs5oh+dfnwspELcRK5AGFOnm79uj+
         kIHF/7BGy9sWhxIxWF5+bs7G4rCJXoy/eXEGmdCCr+eLL+p+f235bcRQYd0CEeN1gIJ9
         BQ/RsPAy6yVMGx4zvXEFwSEO+hCWo8J4ucGaUHQkdAe0FfPnziwh+EK385Tzx1to3J75
         CEMcpYRel7mZmDVYtRZM52EaWViGtlV2gaEI5rScl1vdY8gBJS4BNqUnSGtBTDtwzYag
         rzbaVi782iExc1KQgk9pn4ZcdzCtWcV8lPkHHiAT7hpVD6OIbUSiO7qlr9w222afTS8j
         M+NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=BZh+IhZTMCUUJLzFYWYUuGbrVYqcJiLvSH+0Yd6W0rc=;
        b=oGBghdST6uCf9oFwVpM5MslXesw8YeWpi/DSjCJ3DXDzV3HcZ80lKhwSXbTgQnC6RH
         /ivRyEEPgn1fLeqCoOiyCtZaJb9jvn0RnBKi0OwrJDS+3+KIpS45dbJATLF7PAgR2ORW
         nve04VAr/qsvdYT/FblfQW56BocaUQOnD8OhEfTKGum4i725OFdItdSVjp/iPtkYaH5W
         fO0madB9T+5oprfZqO410gvu6t7mTS336Ft4P9cWwCLZZSfCqXk8AJlynt4RTUL7uDO8
         2Z87iX+BYl4UJKdhkpSu7CRqIdmEHf7p1RbW+OqjSTSNES65cqKQwz1TUh4l3O8JDqH5
         kVNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r33si8556298pjb.76.2019.07.22.09.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 09:16:05 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MGDVcM078068
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:16:04 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twepaduuu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:16:04 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 17:16:03 +0100
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 17:15:54 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MGFrNI55312674
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 16:15:54 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D2013B2067;
	Mon, 22 Jul 2019 16:15:53 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9308AB2064;
	Mon, 22 Jul 2019 16:15:53 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 16:15:53 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 257E516C2E45; Mon, 22 Jul 2019 09:15:55 -0700 (PDT)
Date: Mon, 22 Jul 2019 09:15:55 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
        akpm@linux-foundation.org, christian@brauner.io, davem@davemloft.net,
        ebiederm@xmission.com, elena.reshetova@intel.com, guro@fb.com,
        hch@infradead.org, james.bottomley@hansenpartnership.com,
        jasowang@redhat.com, jglisse@redhat.com, keescook@chromium.org,
        ldv@altlinux.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-parisc@vger.kernel.org, luto@amacapital.net, mhocko@suse.com,
        mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
        syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
        wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Reply-To: paulmck@linux.ibm.com
References: <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722035042-mutt-send-email-mst@kernel.org>
 <20190722115149.GY14271@linux.ibm.com>
 <20190722134152.GA13013@ziepe.ca>
 <20190722155235.GF14271@linux.ibm.com>
 <20190722160448.GH7607@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722160448.GH7607@ziepe.ca>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072216-2213-0000-0000-000003B44BB4
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011475; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235885; UDB=6.00651341; IPR=6.01017236;
 MB=3.00027839; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 16:16:01
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072216-2214-0000-0000-00005F587017
Message-Id: <20190722161555.GJ14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=842 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220180
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 01:04:48PM -0300, Jason Gunthorpe wrote:
> On Mon, Jul 22, 2019 at 08:52:35AM -0700, Paul E. McKenney wrote:
> > So why then is there a problem?
> 
> I'm not sure there is a real problem, I thought Michael was just
> asking how to design with RCU in the case where the user controls the
> kfree_rcu??
> 
> Sounds like the answer is "don't worry about it" ?

Unless you can force failures, you should be good.

And either way, improvements to RCU's handling of this sort of situation
are in the works.  And rcutorture has gained tests of this stuff in the
last year or so as well, see its "fwd_progress" module parameter and
the related code.

							Thanx, Paul

