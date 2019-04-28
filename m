Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2245C4321A
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 05:45:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ED3920881
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 05:45:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ED3920881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D06E06B0003; Sun, 28 Apr 2019 01:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB5846B0006; Sun, 28 Apr 2019 01:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7DFC6B0007; Sun, 28 Apr 2019 01:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9434E6B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:45:17 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id f138so6335523yba.4
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 22:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Z1ZqanrjczSC6xp9Apv/ojFCg2xP/hoDAOgq+a9/JA4=;
        b=rZTfPrRX63QmH026qNMXbh8kT3kzEnntPXyAJdKZjsoaBk9ADkFnbY6yt2zdaCKZ0A
         6pG7rXVzxD4Fxt7nYP13jtmgCjkmZInibobznsKsx0iMqTCR/xB2Gn35L8WPPDyYc2sC
         qn79FyQVdibHeoK3YUbg+I/W0zOlHcM2LSpKBBBuMYGzScsw7zQInUJsP5Eibmonh0k0
         vmV7FmWt9hmzXX7yufBV3nwvegZJ3jqQ94Ep0qimowUnNezaK9ScdCGZYVOkvYKnBwbQ
         +rpRiSkCht1/DbuhDW/4SfiJlv90/8Ocs4eoVLA4+CxILfvFRgqPuB5EZoSmBEL+l3/8
         S32g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUUUG+klSn0W8NnXp0FEaSLb/KGTOPhReTy+zc/rKMcaUZdM6g0
	eJvBxHs/qc2owO4usQHTyghseUM/E3k7SmwzTA6TgNuEr3k7ydS9Wi8tI/ySN9UfAljUW8jCC9m
	Tkmz7y8+fFMFmJFsTWmtWRxKjXbcEVsi7gf9gnIhxLiqc2zBlIOKomAXO95mmNHD1sQ==
X-Received: by 2002:a25:2591:: with SMTP id l139mr708141ybl.518.1556430317321;
        Sat, 27 Apr 2019 22:45:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6QmntO28w+l0uqpyxnUfn5C1SfxdbW1LT6VMndSvX+ozb1di6X71bhMghkovk90xbujfu
X-Received: by 2002:a25:2591:: with SMTP id l139mr708122ybl.518.1556430316601;
        Sat, 27 Apr 2019 22:45:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556430316; cv=none;
        d=google.com; s=arc-20160816;
        b=Axa7Dol/0Yv4LPWzUoEQxn5WKZ1nig7S000N0pppIMZdrrHVXjchE0//NwOuPMLD4Y
         MoReJNWvU0/xzXIMVsh/aLiINzWxT+4Clug4Z6+EoylkabVd5hq6PkAHQbH0/MiOLoUT
         rhOby65EtFXVXtY9GBdMP6buNgxEpaEXacUBvbbZrU8L/vmC3EQFJjr40PQjgUPDwinW
         NqCJ7QNqsPJ/hY2BLdfWzXHLADjkGWZr2jW2Ku81p2/5EQgr9xq0nk2F+RNq4vHiTIBO
         bzsObFSm6jB7scYxLdes4dHVk/pxr2xJlCtXFbY1W8SNvv1EuWaUhKkcL7BoI7FdRzUM
         w+9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Z1ZqanrjczSC6xp9Apv/ojFCg2xP/hoDAOgq+a9/JA4=;
        b=bVEe/7tqRBS87klby9pYfJzZ4TCenhL/O5sHXxeZ627/JY+b5BecHf9he9zkluXuTH
         t4xv3bIu2R5XBxWMaa7wPgfSL7Haa1T1TZi3xWxqXK6+Le5d3iX3YGeG/vawhSGcZHJc
         GImcRCMY300u+sjFMCD9tH1LPuE/J1kRzAz9c+fgeyRj8fYFHEvBttS0Gd1fWrj45m78
         bw2GaNWixwpCk2iOY8j7Tc0KDZUKJfQdNl/JPw+VoCsO9UZwNBJYwUbH6plc/H5tJYwt
         fjBYIp/WPc6C3bAZGq6zfk/rc652O97v/vGz+b3MCXVsQAO3kmkWR0b2A9rcUL4Curr1
         nedA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l15si19098997ybp.11.2019.04.27.22.45.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Apr 2019 22:45:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3S5cag4008142
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:45:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s54h12drm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:45:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 28 Apr 2019 06:45:14 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 28 Apr 2019 06:45:09 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3S5j8gi45023464
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 28 Apr 2019 05:45:08 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A9A88AE055;
	Sun, 28 Apr 2019 05:45:08 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7F4C9AE056;
	Sun, 28 Apr 2019 05:45:07 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 28 Apr 2019 05:45:07 +0000 (GMT)
Date: Sun, 28 Apr 2019 08:45:05 +0300
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
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426074956.GZ4038@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426074956.GZ4038@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042805-0016-0000-0000-00000276086A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042805-0017-0000-0000-000032D28A42
Message-Id: <20190428054505.GC14896@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=515 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904280040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 09:49:56AM +0200, Peter Zijlstra wrote:
> On Fri, Apr 26, 2019 at 12:45:49AM +0300, Mike Rapoport wrote:
> > The initial SCI implementation allows access to any kernel data, but it
> > limits access to the code in the following way:
> > * calls and jumps to known code symbols without offset are allowed
> > * calls and jumps into a known symbol with offset are allowed only if that
> > symbol was already accessed and the offset is in the next page
> > * all other code access are blocked
> 
> So if you have a large function and an in-function jump skips a page
> you're toast.

Right :(
 
> Why not employ the instruction decoder we have and unconditionally allow
> all direct JMP/CALL but verify indirect JMP/CALL and RET ?

Apparently I didn't dig deep enough to find the instruction decoder :)
Surely I can use it.

> Anyway, I'm fearing the overhead of this one, this cannot be fast.

Well, I think that the verification itself is not what will slow things
down the most. IMHO, the major overhead is coming from cr3 switch.

-- 
Sincerely yours,
Mike.

