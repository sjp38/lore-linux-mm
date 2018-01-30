Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4F006B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:28:53 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q63so11307054qtd.12
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:28:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b7si2532446qkf.424.2018.01.30.08.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 08:28:52 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0UGQFM9075935
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:28:51 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ftssgr33k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:28:51 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 30 Jan 2018 16:28:48 -0000
Date: Tue, 30 Jan 2018 08:28:34 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v10 27/27] mm: display pkey in smaps if
 arch_pkeys_enabled() is true
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
 <1516326648-22775-28-git-send-email-linuxram@us.ibm.com>
 <20180130121611.GC26445@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130121611.GC26445@dhcp22.suse.cz>
Message-Id: <20180130162834.GB5411@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Tue, Jan 30, 2018 at 01:16:11PM +0100, Michal Hocko wrote:
> On Thu 18-01-18 17:50:48, Ram Pai wrote:
> [...]
> > @@ -851,9 +848,13 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
> >  			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> >  
> >  	if (!rollup_mode) {
> > -		arch_show_smap(m, vma);
> > +#ifdef CONFIG_ARCH_HAS_PKEYS
> > +		if (arch_pkeys_enabled())
> > +			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> > +#endif
> >  		show_smap_vma_flags(m, vma);
> >  	}
> > +
> 
> Why do you need to add ifdef here? The previous patch should make
> arch_pkeys_enabled == F when CONFIG_ARCH_HAS_PKEYS=n.

You are right. it need not be wrapped in CONFIG_ARCH_HAS_PKEYS.  I had to do it
because vma_pkey(vma)  is not defined in some architectures.

I will provide a generic vma_pkey() definition for architectures that do 
not support PKEYS.



> Btw. could you
> merge those two patches into one. It is usually much easier to review a
> new helper function if it is added along with a user.


ok.

Thanks,
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
