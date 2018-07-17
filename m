Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A40BE6B026A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:59:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12-v6so731285edi.12
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:59:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r17-v6si1196401edd.405.2018.07.17.08.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:59:03 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HFsXBP105124
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:59:01 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k9j7xkxsf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:59:01 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 16:59:00 +0100
Date: Tue, 17 Jul 2018 08:58:48 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 08/24] selftests/vm: fix the wrong assert in
 pkey_disable_set()
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-9-git-send-email-linuxram@us.ibm.com>
 <3c441309-1d35-eead-0c5d-1d7d20018219@intel.com>
MIME-Version: 1.0
In-Reply-To: <3c441309-1d35-eead-0c5d-1d7d20018219@intel.com>
Message-Id: <20180717155848.GA5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 07:47:02AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:44 PM, Ram Pai wrote:
> > If the flag is 0, no bits will be set. Hence we cant expect
> > the resulting bitmap to have a higher value than what it
> > was earlier
> ...
> >  	if (flags)
> > -		pkey_assert(read_pkey_reg() > orig_pkey_reg);
> > +		pkey_assert(read_pkey_reg() >= orig_pkey_reg);
> >  	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
> >  		pkey, flags);
> >  }
> 
> This is the kind of thing where I'd love to hear the motivation and
> background.  This "disable a key that was already disabled" operation
> obviously doesn't happen today.  What motivated you to change it now?

On powerpc, hardware supports READ_DISABLE and WRITE_DISABLE.
ACCESS_DISABLE is basically READ_DISABLE|WRITE_DISABLE on powerpc.

If access disable is called on a key followed by a write disable, the
second operation becomes a nop. In such cases, 
       read_pkey_reg() == orig_pkey_reg


Hence the code above is modified to 
	pkey_assert(read_pkey_reg() >= orig_pkey_reg);


-- 
Ram Pai
