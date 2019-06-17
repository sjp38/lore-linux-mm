Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B737C31E53
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2860A218A0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2860A218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C162E8E0007; Mon, 17 Jun 2019 00:38:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6218E0001; Mon, 17 Jun 2019 00:38:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40F48E0007; Mon, 17 Jun 2019 00:38:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC8D8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j7so6318539pfn.10
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=qupq6HJVpW6yR0/6vTvyHcMi1an+ZHHeFa9yUcwW2zQ=;
        b=HqXgzIK+uNRFTMu6JCNjAzlNqPOF6zy1bCWWLJIbbZJf+zs8TaW+q9bqDPN4rOAV3K
         q/0qIFajGi4EuSR3Q+s3LcTVg9ZjqVvQBc8uZkhooeszuPTFoz7hksyJk0r7ZnQHwXqQ
         Ys5l+E8RAbRhMxPUFKW4iBJI2IKOaiCatAJZB8dm3CT15ivT9752bOg2dDDyhHscrrJj
         zFzHZv5LpqlNRBbhmVbpdYHvnOYjctTiScuNJn204RI3m+tM635Hni6AcYCEkOLfAbwv
         hAW+VJ3jpjjbuhckYwZ6JiYmomZQvLeacwyJwMGPk5jXyfOyoOiG7+1SzS5lDTK5xPYA
         uU/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUeNRfEEvjs/+iYSJ1sRQpo+fkq07/VStSE6gJqXpZRQbeeqN83
	8salhHhcCMat4IVyV5oxxQ+huFX1rx47HJTWeNOcHFQ2SkQdcSQINnFn87R1RJ7rW8/bDGdREhf
	wBF7S4bO/wr31kw24E1LPC/fdGmD28gXYXPcDgzR5msVblF/o1CCLxalqssEqTjOjxQ==
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr26269070pld.174.1560746301063;
        Sun, 16 Jun 2019 21:38:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziI3ysVuXh81TR6EwJ2pXbrc8nDHZ8EZdrhAsI1701Dqc2pJ+jueINN2fAylsCGv16ivfH
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr26269041pld.174.1560746300475;
        Sun, 16 Jun 2019 21:38:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746300; cv=none;
        d=google.com; s=arc-20160816;
        b=jpFuqUuBt+Rk6cdyfMxnV81qj1mqXY8TEhlA1IniqO/IXOUNvld1nTGG4a2z/H+O/g
         CzaMRQY4yZDGMyLWsS1QarUi3XqB5Cx1BCLtb/mlVNZMjWY/xtoEXDGc3HDwrWubmYLu
         NnVMvwXBv/vFr2LSLzVCIazTVxMvSvds8KDq+VBUJJkWHTLJGepIEFsTR5RA3TfwhG6R
         u0v/Ht5LfQK00uqIzmMMBjAkovfNK4n9KOWq84bJkKGH0CM5K50o44Jl8ifrq9R3CMHJ
         4qVAjHpiG3ragVmuncMjTW60KUVP5bsx+ZyV/ig1fMeMfDWLQIcWkQxbmyEhzzgCKibl
         AV3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=qupq6HJVpW6yR0/6vTvyHcMi1an+ZHHeFa9yUcwW2zQ=;
        b=cKZ4v1cbh4MKh/2RLvu3aklX3hdCaRfEzziyCRO1uPofishXQYP2Sv2+4vbRywdi7S
         xlMt4jnKukYgySnRLMKIdtwjCX0WOt65yULgC09SwXEOuOkSrCTefS72U64zAVICPCGP
         OxA4C0Cc28TYbOc4Uyo15xNX+aSJnw7Mtq7Tcz0SWYlqbmIojVzKSBkRlMaWk8iRGfMs
         jLFmdrPVPOC05+uSM29qlcztL9A7cMARH9wjVueN7cDGECQnlLOUCzIUETx4JsDr4yfg
         GLWvKAISrgl292mHnjQNbbPKRRap3oP6wjq78/ck5afp3XWwvOY4InlzSXt/EZUOj4a0
         KXJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f34si9445311plf.258.2019.06.16.21.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4bnXO085945
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:20 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t5vee34dv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:19 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:17 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:38:11 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4cA9P37945852
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:38:10 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6C5354C044;
	Mon, 17 Jun 2019 04:38:10 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18F1D4C05A;
	Mon, 17 Jun 2019 04:38:10 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 17 Jun 2019 04:38:10 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 071D1A0208;
	Mon, 17 Jun 2019 14:38:09 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
        Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large amounts of memory
Date: Mon, 17 Jun 2019 14:36:30 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190617043635.13201-1-alastair@au1.ibm.com>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-4275-0000-0000-00000342E41C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-4276-0000-0000-000038530560
Message-Id: <20190617043635.13201-5-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=928 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

When removing sufficiently large amounts of memory, we trigger RCU stall
detection. By periodically calling cond_resched(), we avoid bogus stall
warnings.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c987d261..382b3a0c9333 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 		__remove_section(zone, __pfn_to_section(pfn), map_offset,
 				 altmap);
 		map_offset = 0;
+
+		if (!(i & 0x0FFF))
+			cond_resched();
 	}
 
 	set_zone_contiguous(zone);
-- 
2.21.0

