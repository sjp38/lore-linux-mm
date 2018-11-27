Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF7326B46C1
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:13:59 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so15280001pls.21
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:13:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g2si2976621pgk.497.2018.11.27.00.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 00:13:59 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAR846aP132659
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:13:58 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p0xv5rcj5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:13:58 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Nov 2018 08:13:56 -0000
Date: Tue, 27 Nov 2018 09:13:50 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
 <20181031100944.GA3546@osiris>
 <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
 <20181127073411.GA3625@osiris>
 <20181127080515.py6naga4gsi2yad2@kshutemo-mobl1>
MIME-Version: 1.0
In-Reply-To: <20181127080515.py6naga4gsi2yad2@kshutemo-mobl1>
Message-Id: <20181127081350.GC3625@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Nov 27, 2018 at 11:05:15AM +0300, Kirill A. Shutemov wrote:
> > E.g. something like the below. If there aren't any objections, I will
> > provide a proper patch with changelog, etc.
> > 
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 07cddff89c7b..d7aeec03c57f 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
> >  	}
> >  
> >  	if (mm_pgtables_bytes(mm))
> > -		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> > -				mm_pgtables_bytes(mm));
> > +		printk_once(KERN_ALERT "BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> > +			    mm_pgtables_bytes(mm));
> 
> You can be the first user of pr_alert_once(). Don't miss a chance! ;)

I didn't expect that that one exists. ;) Will do.
