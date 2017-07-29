Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6376B059D
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:31:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 185so13549449wmk.12
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 16:31:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d31si7716713wma.169.2017.07.29.16.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 16:31:33 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6TNTETg051704
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:31:31 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c0pc5614m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 19:31:31 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 29 Jul 2017 17:31:31 -0600
Date: Sat, 29 Jul 2017 16:31:13 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 20/62] powerpc: store and restore the pkey state across
 context switches
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-21-git-send-email-linuxram@us.ibm.com>
 <878tj94wfo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tj94wfo.fsf@linux.vnet.ibm.com>
Message-Id: <20170729233113.GH5664@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com

On Thu, Jul 27, 2017 at 02:32:59PM -0300, Thiago Jung Bauermann wrote:
> 
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > Store and restore the AMR, IAMR and UMOR register state of the task
> > before scheduling out and after scheduling in, respectively.
> >
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> 
> s/UMOR/UAMOR/
> 
> > diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
> > index 2ad725e..9429361 100644
> > --- a/arch/powerpc/kernel/process.c
> > +++ b/arch/powerpc/kernel/process.c
> > @@ -1096,6 +1096,11 @@ static inline void save_sprs(struct thread_struct *t)
> >  		t->tar = mfspr(SPRN_TAR);
> >  	}
> >  #endif
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +	t->amr = mfspr(SPRN_AMR);
> > +	t->iamr = mfspr(SPRN_IAMR);
> > +	t->uamor = mfspr(SPRN_UAMOR);
> > +#endif
> >  }
> >
> >  static inline void restore_sprs(struct thread_struct *old_thread,
> > @@ -1131,6 +1136,14 @@ static inline void restore_sprs(struct thread_struct *old_thread,
> >  			mtspr(SPRN_TAR, new_thread->tar);
> >  	}
> >  #endif
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +	if (old_thread->amr != new_thread->amr)
> > +		mtspr(SPRN_AMR, new_thread->amr);
> > +	if (old_thread->iamr != new_thread->iamr)
> > +		mtspr(SPRN_IAMR, new_thread->iamr);
> > +	if (old_thread->uamor != new_thread->uamor)
> > +		mtspr(SPRN_UAMOR, new_thread->uamor);
> > +#endif
> >  }
> 
> Shouldn't the saving and restoring of the SPRs be guarded by a check for
> whether memory protection keys are enabled? What happens when trying to
> access these registers on a CPU which doesn't have them?

Good point. need to guard it.  However; i think, these registers have been
available since power6.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
