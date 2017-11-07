Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2B72680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 18:45:25 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id m189so707955qke.21
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 15:45:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c26si2331258qtd.163.2017.11.07.15.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 15:45:24 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA7NjKuc137849
	for <linux-mm@kvack.org>; Tue, 7 Nov 2017 18:45:24 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e3h6vy9ea-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Nov 2017 18:45:18 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 7 Nov 2017 16:44:39 -0700
Date: Tue, 7 Nov 2017 15:44:27 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 00/51] powerpc, mm: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <87efpbm706.fsf@mid.deneb.enyo.de>
 <20171107012218.GA5546@ram.oc3035372033.ibm.com>
 <87h8u6lf27.fsf@mid.deneb.enyo.de>
 <20171107223953.GB5546@ram.oc3035372033.ibm.com>
 <8b970e5b-50e6-bcc1-e8d3-6e3aa8523f55@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b970e5b-50e6-bcc1-e8d3-6e3aa8523f55@intel.com>
Message-Id: <20171107234427.GA5659@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Florian Weimer <fw@deneb.enyo.de>, linux-arch@vger.kernel.org, x86@kernel.org, arnd@arndb.de, corbet@lwn.net, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, mingo@redhat.com, paulus@samba.org, ebiederm@xmission.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, aneesh.kumar@linux.vnet.ibm.com

On Tue, Nov 07, 2017 at 02:47:10PM -0800, Dave Hansen wrote:
> On 11/07/2017 02:39 PM, Ram Pai wrote:
> > 
> > As per the current semantics of sys_pkey_free(); the way I understand it,
> > the calling thread is saying disassociate me from this key.
> 
> No.  It is saying: "this *process* no longer has any uses of this key,
> it can be reused".

ok, in light of the corrected semantics, I see no bug in the implimentation.

> On Mon, Nov 06, 2017 at 10:28:41PM +0100, Florian Weimer wrote:
...
> The problem is a pkey_alloc/pthread_create/pkey_free/pkey_alloc
> sequence.  The pthread_create call makes the new thread inherit the
> access rights of the current thread, but then the key is deallocated.
> Reallocation of the same key will have that thread retain its access
> rights, which is IMHO not correct.

Again.. in light of the corrected semantics --
 the child thread or any thread should not free
a key without cleaning up. 
(a) disassociate the key from its address space
(b) reset the permission on the key across all the threads of the
process.

Because any such uncleaned bits can cause unexpected behavior if the 
same key gets reallocated on sys_pkey_alloc().


-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
