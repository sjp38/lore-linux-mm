Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDF16B026C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:00:56 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u11-v6so1309129oif.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:00:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q131-v6si787662oia.196.2018.07.17.09.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:00:55 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HG07Ti031120
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:00:54 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k9ggqgy13-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:00:51 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:00:48 +0100
Date: Tue, 17 Jul 2018 09:00:36 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 10/24] selftests/vm: clear the bits in shadow reg
 when a pkey is freed.
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-11-git-send-email-linuxram@us.ibm.com>
 <41034628-c643-7a4b-006d-9606201ded6e@intel.com>
MIME-Version: 1.0
In-Reply-To: <41034628-c643-7a4b-006d-9606201ded6e@intel.com>
Message-Id: <20180717160036.GB5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 07:49:31AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:45 PM, Ram Pai wrote:
> > When a key is freed, the  key  is  no  more  effective.
> > Clear the bits corresponding to the pkey in the shadow
> > register. Otherwise  it  will carry some spurious bits
> > which can trigger false-positive asserts.
> ...--- a/tools/testing/selftests/vm/protection_keys.c
> > +++ b/tools/testing/selftests/vm/protection_keys.c
> > @@ -556,6 +556,9 @@ int alloc_pkey(void)
> >  int sys_pkey_free(unsigned long pkey)
> >  {
> >  	int ret = syscall(SYS_pkey_free, pkey);
> > +
> > +	if (!ret)
> > +		shadow_pkey_reg &= clear_pkey_flags(pkey, PKEY_DISABLE_ACCESS);
> >  	dprintf1("%s(pkey=%ld) syscall ret: %d\n", __func__, pkey, ret);
> >  	return ret;
> >  }
> 
> This would be great code for an actual application.  But, I'm not
> immediately convinced we want sane, kind behavior in our selftest.  x86
> doesn't clear the hardware register at pkey_free, so wouldn't this cause
> the shadow and the hardware register to diverge?

Have deleted the code in the newer version.

RP
