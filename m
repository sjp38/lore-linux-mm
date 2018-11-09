Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC6D6B0716
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 13:10:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id k125so1686132pga.5
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 10:10:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id gn20si3974910plb.273.2018.11.09.10.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 10:10:01 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA9I8vXO143847
	for <linux-mm@kvack.org>; Fri, 9 Nov 2018 13:10:01 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nnby30xhp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Nov 2018 13:10:00 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 9 Nov 2018 18:09:58 -0000
Date: Fri, 9 Nov 2018 10:09:47 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
 <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
 <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <87bm6z71yw.fsf@oldenburg.str.redhat.com>
Message-Id: <20181109180947.GF5481@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-api@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, Nov 08, 2018 at 09:23:35PM +0100, Florian Weimer wrote:
> * Ram Pai:
> 
> > Florian,
> >
> > 	I can. But I am struggling to understand the requirement. Why is
> > 	this needed?  Are we proposing a enhancement to the sys_pkey_alloc(),
> > 	to be able to allocate keys that are initialied to disable-read
> > 	only?
> 
> Yes, I think that would be a natural consequence.
> 
> However, my immediate need comes from the fact that the AMR register can
> contain a flag combination that is not possible to represent with the
> existing PKEY_DISABLE_WRITE and PKEY_DISABLE_ACCESS flags.  User code
> could write to AMR directly, so I cannot rule out that certain flag
> combinations exist there.
> 
> So I came up with this:
> 
> int
> pkey_get (int key)
> {
>   if (key < 0 || key > PKEY_MAX)
>     {
>       __set_errno (EINVAL);
>       return -1;
>     }
>   unsigned int index = pkey_index (key);
>   unsigned long int amr = pkey_read ();
>   unsigned int bits = (amr >> index) & 3;
> 
>   /* Translate from AMR values.  PKEY_AMR_READ standing alone is not
>      currently representable.  */
>   if (bits & PKEY_AMR_READ)

this should be
   if (bits & (PKEY_AMR_READ|PKEY_AMR_WRITE))


>     return PKEY_DISABLE_ACCESS;


>   else if (bits == PKEY_AMR_WRITE)
>     return PKEY_DISABLE_WRITE;
>   return 0;
> }
> 
> And this is not ideal.  I would prefer something like this instead:
> 
>   switch (bits)
>     {
>       case PKEY_AMR_READ | PKEY_AMR_WRITE:
>         return PKEY_DISABLE_ACCESS;
>       case PKEY_AMR_READ:
>         return PKEY_DISABLE_READ;
>       case PKEY_AMR_WRITE:
>         return PKEY_DISABLE_WRITE;
>       case 0:
>         return 0;
>     }

yes.
 and on x86 it will be something like:
   switch (bits)
     {
       case PKEY_PKRU_ACCESS :
         return PKEY_DISABLE_ACCESS;
       case PKEY_AMR_WRITE:
         return PKEY_DISABLE_WRITE;
       case 0:
         return 0;
     }

But for this to work, why do you need to enhance the sys_pkey_alloc()
interface?  Not that I am against it. Trying to understand if the
enhancement is really needed.

> 
> By the way, is the AMR register 64-bit or 32-bit on 32-bit POWER?

It is 64-bit.

RP
