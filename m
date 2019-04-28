Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31E72C43218
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 05:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D77B220881
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 05:47:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D77B220881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FAE66B0006; Sun, 28 Apr 2019 01:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AAF16B0008; Sun, 28 Apr 2019 01:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 675286B000A; Sun, 28 Apr 2019 01:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 304536B0006
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:47:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p8so5153289pfd.4
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 22:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=cFoXT26Ut5J38gNbrWm0ZX2oaBdIiGTgJzTQo+EfHms=;
        b=RJ1K+bghcQXLwcutsCZ3kbBT7JfZ9eKIcRcJtr/UeTx2WyuS9rz/hKi/QiyM+AuGKe
         gLy4jz87ayVk7GmuQkkRWqhIjYnshFGGEUMu4DWrtX1CXVH5N0wWe8gIsUyR6WduUByE
         3IIah5rR2Oj0MtjQoWo0SuLE9iFj58+cNkEW13iiciCg3YJrnb2wjTiaCDa9DL94KjPz
         uU6ZMxFPpv/1cC+IomeISKPb3FvhevyzP0JnqMj6INLiYxuu4ZPIcGEWVC9KS6crCVpF
         Ms2IjX5uoHq7zlFNMgR9SH/bFMT7moatlzvB7negDkvyaHSODr/QA6LyD0QxCu3DjoLV
         7Kxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWl6IhrmIiLSpyrZKdRLXXbZ4ewCzjo3w88RtdFKpv6kWdBA3Cp
	I4Kvdy7qTPoi1SnmXh1MOczF12TreCwsFIdGD5IqBFszwWRfuLCE0C39IPEZIPIgPotSyr+XJ8e
	GMVgoVAq5WzySb5vqEfbHzKT9IUcXPup7PaT2dJAGRBgYBRqZT7iGdAFsZhYJmfv9cA==
X-Received: by 2002:a17:902:42:: with SMTP id 60mr55320316pla.79.1556430444858;
        Sat, 27 Apr 2019 22:47:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGZ6wd1b+v6d0kTK3d1262BlmSCboowaUhvnaozEtTO2+2LllSJGihCoFfGn5leAUXY0iF
X-Received: by 2002:a17:902:42:: with SMTP id 60mr55320281pla.79.1556430444175;
        Sat, 27 Apr 2019 22:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556430444; cv=none;
        d=google.com; s=arc-20160816;
        b=rx0iP42SzA6/P8XJxvbu9AyIytYvD+PIOGpn6ErD71FPpHjyJdam0Twz1hw1BzQe6j
         GJdu1CyH4n2pG+U+Em1PESGLSiWb3cHhdiAUrhAwlBGNseYgREYHumLbiEFJW9VqIlke
         6yfUbxMxG4EkDDyinUiZ1LeyIfWoEKBDhpRw/1WFzQZ03xHbrLGhk+UvNz7euczfl9sB
         GogzFxQtqZzyHE0Sz7qOZN9BCTFBc/Y8HY9Tsc+TMJJOUZx7ssuyPmpJY7padcZF66bY
         DyQqpcWvTHpI7SFAAnLghKszhJTB7eVPdW1NgrrUBdVyNtKX1nHnLUdSyYQi87G32NeX
         Lwzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=cFoXT26Ut5J38gNbrWm0ZX2oaBdIiGTgJzTQo+EfHms=;
        b=hgeM1B5+7xnYt/NxOdpOacSFHKT4/Gn4Rr9qvDDN/wR5BcYCzS09lo8ccL3S61qzR0
         hYdcWOqwS3Fk7qidiivgo7sgeXDM5HDVGXOeYkW75lPECBJqlQhsM1/HdIhi36Z3wWWD
         vlE9+0HQRzr4SOWjdmCfFlutEbjLyVDq94c2ho6jGDu+vF9tfP1MhcEL2ad45my1rZKW
         Pq1LLhBO8CTC1oXAJ0DTr26OiUjmQ8jX+OLaz82KzcQJiBskRh+VjIrDDepEdIendRC4
         DjuQUr4oLXgzBwfFV+brxX9A3IlLjfCXd3vhz8Nf8YwkA6h+prCC2TvqAVytdRsuhI5d
         rQsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k12si27190633pgo.429.2019.04.27.22.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Apr 2019 22:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3S5dTmJ055933
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:47:23 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s54kvt748-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:47:23 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 28 Apr 2019 06:47:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 28 Apr 2019 06:47:15 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3S5lE3355115962
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 28 Apr 2019 05:47:14 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A6EF311C04C;
	Sun, 28 Apr 2019 05:47:14 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7CB1D11C04A;
	Sun, 28 Apr 2019 05:47:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 28 Apr 2019 05:47:13 +0000 (GMT)
Date: Sun, 28 Apr 2019 08:47:11 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Thomas Gleixner <tglx@linutronix.de>,
        linux-mm@kvack.org, linux-security-module@vger.kernel.org,
        x86@kernel.org
Subject: Re: [RFC PATCH 5/7] x86/mm/fault: hook up SCI verification
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-6-git-send-email-rppt@linux.ibm.com>
 <20190426074223.GY4038@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426074223.GY4038@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042805-0012-0000-0000-000003160447
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042805-0013-0000-0000-0000214E65F8
Message-Id: <20190428054711.GD14896@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=414 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904280040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 09:42:23AM +0200, Peter Zijlstra wrote:
> On Fri, Apr 26, 2019 at 12:45:52AM +0300, Mike Rapoport wrote:
> > If a system call runs in isolated context, it's accesses to kernel code and
> > data will be verified by SCI susbsytem.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  arch/x86/mm/fault.c | 28 ++++++++++++++++++++++++++++
> >  1 file changed, 28 insertions(+)
> 
> There's a distinct lack of touching do_double_fault(). It appears to me
> that you'll instantly trigger #DF when you #PF, because the #PF handler
> itself will not be able to run.

The #PF handler is able to run. On interrupt/error entry the cr3 is
switched to the full kernel page tables, pretty much like PTI does for
user <-> kernel transitions. It's in the patch 3.
 
> And then obviously you have to be very careful to make sure #DF can,
> _at_all_times_ run, otherwise you'll tripple-fault and we all know what
> that does.
> 

-- 
Sincerely yours,
Mike.

