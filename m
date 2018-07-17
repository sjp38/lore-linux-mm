Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC5B26B026E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:02:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j5-v6so1364051oiw.13
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:02:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e133-v6si877593oib.118.2018.07.17.09.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:02:34 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HFxnWv038569
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:02:33 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k9jsujgjx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:02:33 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:02:30 +0100
Date: Tue, 17 Jul 2018 09:02:18 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 13/24] selftests/vm: pkey register should match
 shadow pkey
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-14-git-send-email-linuxram@us.ibm.com>
 <6246f823-77d9-6727-097e-73f103078a44@intel.com>
MIME-Version: 1.0
In-Reply-To: <6246f823-77d9-6727-097e-73f103078a44@intel.com>
Message-Id: <20180717160218.GC5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 07:53:57AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:45 PM, Ram Pai wrote:
> > +++ b/tools/testing/selftests/vm/protection_keys.c
> > @@ -916,10 +916,10 @@ void expected_pkey_fault(int pkey)
> >  		pkey_assert(last_si_pkey == pkey);
> >  
> >  	/*
> > -	 * The signal handler shold have cleared out PKEY register to let the
> > +	 * The signal handler should have cleared out pkey-register to let the
> >  	 * test program continue.  We now have to restore it.
> >  	 */
> > -	if (__read_pkey_reg() != 0)
> > +	if (__read_pkey_reg() != shadow_pkey_reg)
> >  		pkey_assert(0);
> >  
> >  	__write_pkey_reg(shadow_pkey_reg);
> 
> I think this is wrong on x86.
> 
> When we leave the signal handler, we zero out PKRU so that the faulting
> instruction can continue, that's why we have the check against zero.
> I'm actually kinda surprised this works.

The code is modified to zero out only the violated key in the signal
handler. Hence it works. Have verified it to work on x86 aswell.

RP
