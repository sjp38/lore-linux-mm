Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7FDF440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 18:38:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l188so1558167wma.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 15:38:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i9si7393410edj.500.2017.11.09.15.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 15:37:59 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA9NZ3AE050568
	for <linux-mm@kvack.org>; Thu, 9 Nov 2017 18:37:58 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e50t4r54u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Nov 2017 18:37:57 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 9 Nov 2017 16:37:56 -0700
Date: Thu, 9 Nov 2017 15:37:46 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 44/51] selftest/vm: powerpc implementation for generic
 abstraction
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-45-git-send-email-linuxram@us.ibm.com>
 <20171109184714.xs523k4cvmqghew3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109184714.xs523k4cvmqghew3@gmail.com>
Message-Id: <20171109233745.GD5546@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Breno Leitao <leitao@debian.org>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Thu, Nov 09, 2017 at 04:47:15PM -0200, Breno Leitao wrote:
> Hi Ram,
> 
> On Mon, Nov 06, 2017 at 12:57:36AM -0800, Ram Pai wrote:
> > @@ -206,12 +209,14 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
> >  
> >  	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
> >  	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
> > -	fpregset = uctxt->uc_mcontext.fpregs;
> > -	fpregs = (void *)fpregset;
> 
> Since you removed all references for fpregset now, you probably want to
> remove the declaration of the variable above.

fpregs is still needed.

> 
> > @@ -219,20 +224,21 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
> >  	 * state.  We just assume that it is here.
> >  	 */
> >  	fpregs += 0x70;
> > -#endif
> > -	pkey_reg_offset = pkey_reg_xstate_offset();
> 
> With this code, you removed all the reference for variable
> pkey_reg_offset, thus, its declaration could be removed also.

yes. will fix it.

> 
> > -	*(u64 *)pkey_reg_ptr = 0x00000000;
> > +	dprintf1("si_pkey from siginfo: %lx\n", si_pkey);
> > +#if defined(__i386__) || defined(__x86_64__) /* arch */
> > +	dprintf1("signal pkey_reg from xsave: %016lx\n", *pkey_reg_ptr);
> > +	*(u64 *)pkey_reg_ptr &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
> > +#elif __powerpc64__
> 
> Since the variable pkey_reg_ptr is only used for Intel code (inside
> #ifdefs), you probably want to #ifdef the variable declaration also,
> avoid triggering "unused variable" warning on non-Intel machines.

yes. Actually it will trigger the warning on intel machines. Fixed it.

Thanks Breno!
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
