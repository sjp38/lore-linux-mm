Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E1B3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8B5C21871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:59:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pFm6fjQw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8B5C21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20BAF6B02C8; Fri, 15 Mar 2019 16:59:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C32D6B02CA; Fri, 15 Mar 2019 16:59:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 083DD6B02C9; Fri, 15 Mar 2019 16:59:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5C1D6B02C7
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 16:59:11 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id g140so11674933ywb.12
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WIHZ68eIEhQn/ZXc0eoyLeJRbce8uJxo/rZHur5TnXk=;
        b=fS+XgECF+Jd6Te0hePWGo7TfG85Sf3suW6yPACizi60m9sR7RfxMcbetC72Q9Haa+c
         g+WvPGdZuVNK9O+quzM4bmvq5GmzkIAXLRfPbRZ2meDQW/zZmugPw/iPn90bzA4gz8QX
         1mA95O93JGXYTMemLtWL+gdy37vJtsg5DARMasSdb/2M8PFHTNgZ3L7pADhUHkGZe/Lx
         t58hWNXEx+Wns/qRzkfI2rwp+7H9UBqB+Uzf1UVwGusU54x0bp1Sq8RZSOewhZfcWE0A
         pJ9Zwy9tw9hIY5y2S/aFD+nEBF59BfIHnZrucGWHGAyIJbmttbHyanYnz9Q44R5LWGHB
         z3Ng==
X-Gm-Message-State: APjAAAV23mArn1FcdAFRhHDV08gW0oY9tFIwptWS6gJ6/N7IcEJZhzGi
	BF2i4OYfAq1gslEHX74uMdXgjzqjA/fN3mnIT/Vb/+c4vHg1wT3Aae9oKX5KSh0XNYSXT80KMZ6
	yOYmDNAQATvRP3qF0d0ll96HHglrFJw85XKBb2h2A1+8p7qpWwigGmna0fOnjp1us9g==
X-Received: by 2002:a81:3253:: with SMTP id y80mr4669942ywy.63.1552683551572;
        Fri, 15 Mar 2019 13:59:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9XlFVmDeg4XSo54wGeY+nxdmh58bHmhVETpKd0CR7w/rotlTTkKdmvbG6kSzQNDCj7f8Q
X-Received: by 2002:a81:3253:: with SMTP id y80mr4669881ywy.63.1552683550418;
        Fri, 15 Mar 2019 13:59:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552683550; cv=none;
        d=google.com; s=arc-20160816;
        b=KTO4x9DvaBkErjbVvFFhtgcb/IFoNcaLRQ+6KCu2iuoc0OCNZGZt4LQST944Km43Ff
         aTu204eZcnofUyUSGSvWEt41n+D+ek5LfsMKzltjl/0KzIiOjI0PguqOnvMJRRbi3iOx
         Y7sxWE3FoRZNHL6mcJqYxNRNxePdb47dJHYBwzSPtuy9NtXwnQj4yvvUUaEzEuZufHhb
         /TXtUinO0IMLXsFOtXphE5qbY35jXkbhBpNua+k2kSZ4FEjhk72Qk8+rVdhkSUBPObb9
         nTq9AI78KQ0zo994bSX0gCoN44xv23HOWI0tA7XhkylNlFKPCjAKmgXiuGb1S4cVEWdS
         cyzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WIHZ68eIEhQn/ZXc0eoyLeJRbce8uJxo/rZHur5TnXk=;
        b=r78XnYJvRYY1vzx6whBFQB1G3K2KXeD8yny8KvmZhnxsMD5YW//thJwxtRQW4FJOFW
         FHjnqQYRiXLNPh3hA/Wd5yAvOO04HZn9qrqQIS+wDkHQwYfT/X5o6vToLm6XqVp2tiW1
         K+CZxbzYapQWl1hflFjJ5N85kFFWq6t5BMupPhQg+t7SggPoS3YNOlt5295l7oOX/RbT
         +bWDTZRWjTLqm205Di1SvcsoDXqvr3ZtQqL96NMPSHFJlbvDj/fyLrfYaeORlFqbRE2A
         u6H0qBLzdqcb49j7Hh5wjpwC7grEy+43oOp/IX/m8RyigGFqY250SE1V5EfxSUVYgiIg
         zqkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pFm6fjQw;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z62si1883128yba.9.2019.03.15.13.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 13:59:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pFm6fjQw;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2FKx1h0046094;
	Fri, 15 Mar 2019 20:59:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=WIHZ68eIEhQn/ZXc0eoyLeJRbce8uJxo/rZHur5TnXk=;
 b=pFm6fjQwlkUmSbi7EudQD0luLd5BgOiW2iiAOIwCb39bH6TtTnwfPa9WyaQAEQyO8Lpb
 ZcE1VvHu5wh6O1GiG7q0nnVOMRYYU3s0NvO3nK7cbAPmhGwR24SC/9BsRDG4Wjr4vdSa
 T0q9Ettu4pxUbe8k1T9IW8beut0flGMM35AccQS+vF5THjMxgAZE0UpMqq/hACGH4sY+
 Ea9TI16OxHtk6Ogw2PzlBx+3uCtgVvAV6EIWuM4Rc7FzE+J5QHU0iL1LmDKPpUplPkAI
 SoXevfFbwwYVvmbP3JX1nuc1cVZa7gCq7aShKKggSBLTQC6PTU+uOB8OuyARW0XaV0ok 7g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2r464s0wfv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Mar 2019 20:59:06 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2FKx5eZ004783
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 15 Mar 2019 20:59:05 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2FKx3km005096;
	Fri, 15 Mar 2019 20:59:04 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 15 Mar 2019 20:59:03 +0000
Date: Fri, 15 Mar 2019 16:58:27 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, mgorman@techsingularity.net, cai@lca.pw,
        vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9196 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903150143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> Hi folks.
> I am observed kernel panic after updated to git commit 610cd4eadec4.
> I am did not make git bisect because this crashes occurs spontaneously
> and I not have exactly instruction how reproduce it.
> 
> Hope backtrace below could help understand how fix it:
> 
> page:ffffef46607ce000 is uninitialized and poisoned
> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> ------------[ cut here ]------------
> kernel BUG at include/linux/mm.h:1020!
> invalid opcode: 0000 [#1] SMP NOPTI
> CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
> 5.1.0-0.rc0.git4.1.fc31.x86_64 #1
> Hardware name: System manufacturer System Product Name/ROG STRIX
> X470-I GAMING, BIOS 1201 12/07/2018
> RIP: 0010:__reset_isolation_pfn+0x244/0x2b0

This is new code, from e332f741a8dd1 ("mm, compaction: be selective about what
pageblocks to clear skip hints"), so I added some folks.

Can you show
$LINUX/scripts/faddr2line path/to/vmlinux __reset_isolation_pfn+0x244
?

