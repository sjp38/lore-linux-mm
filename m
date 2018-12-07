Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85BCA6B7F03
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 01:39:26 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id k125so1925684pga.5
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 22:39:26 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id s17si2095632pgi.513.2018.12.06.22.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 22:39:25 -0800 (PST)
Date: Thu, 6 Dec 2018 22:39:19 -0800
From: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 12/13] keys/mktme: Save MKTME data if kernel cmdline
 parameter allows
Message-ID: <20181207063918.GB12969@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c2668d6d260bff3c88440ad097eb1445ea005860.1543903910.git.alison.schofield@intel.com>
 <1544148839.28511.28.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1544148839.28511.28.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Thu, Dec 06, 2018 at 06:14:03PM -0800, Huang, Kai wrote:
> On Mon, 2018-12-03 at 23:39 -0800, Alison Schofield wrote:
> > MKTME (Multi-Key Total Memory Encryption) key payloads may include
> > data encryption keys, tweak keys, and additional entropy bits. These
> > are used to program the MKTME encryption hardware. By default, the
> > kernel destroys this payload data once the hardware is programmed.
> > 
> > However, in order to fully support CPU Hotplug, saving the key data
> > becomes important. The MKTME Key Service cannot allow a new physical
> > package to come online unless it can program the new packages Key Table
> > to match the Key Tables of all existing physical packages.
> > 
> > With CPU generated keys (a.k.a. random keys or ephemeral keys) the
> > saving of user key data is not an issue. The kernel and MKTME hardware
> > can generate strong encryption keys without recalling any user supplied
> > data.
> > 
> > With USER directed keys (a.k.a. user type) saving the key programming
> > data (data and tweak key) becomes an issue. The data and tweak keys
> > are required to program those keys on a new physical package.
> > 
> > In preparation for adding CPU hotplug support:
> > 
> >    Add an 'mktme_vault' where key data is stored.
> > 
> >    Add 'mktme_savekeys' kernel command line parameter that directs
> >    what key data can be stored. If it is not set, kernel does not
> >    store users data key or tweak key.
> > 
> >    Add 'mktme_bitmap_user_type' to track when USER type keys are in
> >    use. If no USER type keys are currently in use, a physical package
> >    may be brought online, despite the absence of 'mktme_savekeys'.
> 
> Overall, I am not sure whether saving key is good idea, since it
> breaks coldboot attack IMHO. We need to tradeoff between supporting
> CPU hotplug and security. I am not sure whether supporting CPU hotplug
> is that important, since for some other features such as SGX, we don't
> support CPU hotplug anyway.

What is the application for saving the key anyway?

With my current knowledge, I'm not even sure what is the application
for user provided keys.

/Jarkko
