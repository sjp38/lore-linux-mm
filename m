Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 154916B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:31:37 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c9so10930493wrb.4
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:31:37 -0800 (PST)
Received: from telmad-lavadora-l1mail2.puc.rediris.es (te-l1mail2-out03a.puc.rediris.es. [2001:720:418:ca03::85])
        by mx.google.com with ESMTPS id s130si858835wmf.256.2017.12.19.00.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 00:31:35 -0800 (PST)
Date: Tue, 19 Dec 2017 09:31:22 +0100
From: Gabriel Paubert <paubert@iram.es>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
Message-ID: <20171219083122.q7ycxg2dfspgzw7z@lt-gp.iram.es>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
 <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
 <20171218231551.GA5481@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218231551.GA5481@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, mingo@redhat.com, paulus@samba.org, ebiederm@xmission.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, aneesh.kumar@linux.vnet.ibm.com

On Mon, Dec 18, 2017 at 03:15:51PM -0800, Ram Pai wrote:
> On Mon, Dec 18, 2017 at 02:28:14PM -0800, Dave Hansen wrote:
> > On 12/18/2017 02:18 PM, Ram Pai wrote:
> > > b) minimum number of keys available to the application.
> > > 	if libraries consumes a few, they could provide a library
> > > 	interface to the application informing the number available to
> > > 	the application.  The library interface can leverage (b) to
> > > 	provide the information.
> > 
> > OK, let's see a real user of this including a few libraries.  Then we'll
> > put it in the kernel.
> > 
> > > c) types of disable-rights supported by keys.
> > > 	Helps the application to determine the types of disable-features
> > > 	available. This is helpful, otherwise the app has to 
> > > 	make pkey_alloc() call with the corresponding parameter set
> > > 	and see if it suceeds or fails. Painful from an application
> > > 	point of view, in my opinion.
> > 
> > Again, let's see a real-world use of this.  How does it look?  How does
> > an app "fall back" if it can't set a restriction the way it wants to?
> > 
> > Are we *sure* that such an interface makes sense?  For instance, will it
> > be possible for some keys to be execute-disable while other are only
> > write-disable?
> 
> Can it be on x86?
> 
> its not possible on ppc. the keys can *all* be  the-same-attributes-disable all the
> time.
> 
> However you are right. Its conceivable that some arch could provide a
> feature where it can be x-attribute-disable for key 'a' and
> y-attribute-disable for key 'b'.  But than its a bit of a headache
> for an application to consume such a feature.
> 
> Ben: I recall you requesting this feature.  Thoughts?
> 
> > 
> > > I think on x86 you look for some hardware registers to determine
> > > which hardware features are enabled by the kernel.
> > 
> > No, we use CPUID.  It's a part of the ISA that's designed for
> > enumerating CPU and (sometimes) OS support for CPU features.
> > 
> > > We do not have generic support for something like that on ppc.  The
> > > kernel looks at the device tree to determine what hardware features
> > > are available. But does not have mechanism to tell the hardware to
> > > track which of its features are currently enabled/used by the
> > > kernel; atleast not for the memory-key feature.
> > 
> > Bummer.  You're missing out.
> > 
> > But, you could still do this with a syscall.  "Hey, kernel, do you
> > support this feature?"
> 
> or do powerpc specific sysfs interface.
> or a debugfs interface.

getauxval(3) ?

With AT_HWCAP or HWCAP2 as parameter already gives information about
features supported by the hardware and the kernel.

Taking one bit to expose the availability of protection keys to
applications does not look impossible.

Do I miss something obvious?

	Gabriel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
