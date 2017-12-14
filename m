Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0EB26B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:18:05 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f9so3374278qtf.6
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:18:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k42si3190826qtf.429.2017.12.13.16.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 16:18:05 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBE0GHco096284
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:18:04 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eub3tymqy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:18:03 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 13 Dec 2017 19:18:02 -0500
Date: Wed, 13 Dec 2017 16:17:56 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Support setting access rights for signal handlers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
 <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
 <c220f36f-c04a-50ae-3fd7-2c6245e27057@intel.com>
 <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
Message-Id: <20171214001756.GA5471@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Wed, Dec 13, 2017 at 04:40:11PM +0100, Florian Weimer wrote:
> On 12/13/2017 04:22 PM, Dave Hansen wrote:
> >On 12/13/2017 07:08 AM, Florian Weimer wrote:
> >>Okay, this model is really quite different from x86.  Is there a
> >>good reason for the difference?
> >
> >Yes, both implementations are simple and take the "natural" behavior.
> >x86 changes XSAVE-controlled register values on entering a signal, so we
> >let them be changed (including PKRU).  POWER hardware does not do this
> >to its PKRU-equivalent, so we do not force it to.
> 
> Whuy?  Is there a technical reason not have fully-aligned behavior?
> Can POWER at least implement the original PKEY_ALLOC_SETSIGNAL
> semantics (reset the access rights for certain keys before switching
> to the signal handler) in a reasonably efficient manner?

This can be done on POWER. I can also change the behavior on POWER
to exactly match x86; i.e reset the value to init value before
calling the signal handler.

But I think, we should clearly define the default behavior, the behavior
when no flag is specified. Applications tend to rely on default behavior
and expect the most intuitive behavior to be the default behavior.

I tend to think; keeping my biases aside, that the most intuitive
behavior is to preserve access/write permissions of any key, i.e not
reset to the init value.  If the application has set the permissions of
a key to some value, it would'nt expect anyone to change them,
irrespective of which context it is in.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
