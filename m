Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEDE98E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 15:10:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bg5-v6so10412054plb.20
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 12:10:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q61-v6si16897720plb.231.2018.09.10.12.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 12:10:26 -0700 (PDT)
Date: Mon, 10 Sep 2018 12:10:59 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 00/12] Multi-Key Total Memory Encryption API (MKTME)
Message-ID: <20180910191059.GA26529@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424961@PGSMSX112.gar.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <105F7BF4D0229846AF094488D65A098935424961@PGSMSX112.gar.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Sep 09, 2018 at 06:10:19PM -0700, Huang, Kai wrote:
> 
> > -----Original Message-----
> > From: keyrings-owner@vger.kernel.org [mailto:keyrings-
> > owner@vger.kernel.org] On Behalf Of Alison Schofield
> > Sent: Saturday, September 8, 2018 10:23 AM
> > To: dhowells@redhat.com; tglx@linutronix.de
> > Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> > <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> > Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> > <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> > linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> > x86@kernel.org; linux-mm@kvack.org
> > Subject: [RFC 00/12] Multi-Key Total Memory Encryption API (MKTME)
> > 
> > Seeking comments on the APIs supporting MKTME on future Intel platforms.
> > 
> > MKTME (Multi-Key Total Memory Encryption) is a technology supporting
> > memory encryption on upcoming Intel platforms. Whereas TME allows
> > encryption of the entire system memory using a single key, MKTME allows
> > mulitple encryption domains, each having their own key. While the main use
> > case for the feature is virtual machine isolation, the API needs the flexibility to
> > work for a wide range of use cases.
> > 
> > This RFC presents the 2 API additions that enable userspace to:
> >  1) Create Encryption Keys: Kernel Key Service type "mktme"
> >  2) Use the Encryption Keys: system call encrypt_mprotect()
> > 
> > In order to share between: the Kernel Key Service, the new system call, and the
> > existing mm code, helper functions were created in arch/x86/mktme
> 
> IMHO, we can separate this series into 2 parts, as you did above, and send out them separately. The reason is, in general I think adding new MKTME type to key retention services is not that related to memory management code, namely the encrypt_mprotect() API part.
> 
> So if we split the two parts and send them out separately, the first part can be reviewed by keyring and security guys, without involving mm guys, and the encrypt_mprotect() part can be more reviewed more by mm guys. 
> 

Kai,

That was the direction I had in mind at the onset: the MKTME key service
would be one patch(set) and the MKTME encrypt_mprotect() system call would
be delivered in another patch(set).

That separation falls apart when the shared structures and functions are
introduced. That 'mktme_map' (maps userspace keys to hardware keyid slots),
and the 'encrypt_count' array (counts vma's outstanding for each key) need
to be shared by both pieces. These mktme special shared structures and the
functions that operate on them are all defined in arch/x86/mm/mktme.h,.c.
>From there they can be shared with the security/keys/mktme_keys.c

Once I made that separation, I stuck with it. Those structures, and any
functions that manipulate those structures live in arch/x86/mm/mktme.h,c

You noted that some of the functions that operate on the encrypt_count
might not need to be over in arch/x86/mm/mktme.c because they are not used
in the mm code. That is true.  But, then I'd be splitting up the definition
of the struct and the funcs that operate on it. So, I stuck with keeping it
all together in the arch specific mktme files.

Having said all the above, I do welcome other ideas on how to better organize
the code. 

Back to your request- to split it into smaller patchsets might look something
like:
1) the MKTME API helpers
2) the MKTME Key Service
3) the MKTME syscall encrypt_mprotect()

I'm not clear that would make anyones review life easier, than picking
the same pieces out of the greater patchset.

Suggestions welcome,
Alison

> And since encrypt_mprotect() is a new syscall, you may need to add more lists for the review, ie, linux-api, and maybe linux-kernel as well.

Got it. Will include theses in v1.

> 
> Thanks,
> -Kai
> 
> > 
> > This patchset is built upon Kirill Shutemov's patchset for the core MKTME
> > support. You can find that here:
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git mktme/wip
> > 
> > 
> > Alison Schofield (12):
> >   docs/x86: Document the Multi-Key Total Memory Encryption API
> >   mm: Generalize the mprotect implementation to support extensions
> >   syscall/x86: Wire up a new system call for memory encryption keys
> >   x86/mm: Add helper functions to manage memory encryption keys
> >   x86/mm: Add a helper function to set keyid bits in encrypted VMA's
> >   mm: Add the encrypt_mprotect() system call
> >   x86/mm: Add helper functions to track encrypted VMA's
> >   mm: Track VMA's in use for each memory encryption keyid
> >   mm: Restrict memory encryption to anonymous VMA's
> >   x86/pconfig: Program memory encryption keys on a system-wide basis
> >   keys/mktme: Add a new key service type for memory encryption keys
> >   keys/mktme: Do not revoke in use memory encryption keys
> > 
> >  Documentation/x86/mktme-keys.txt       | 153 ++++++++++++++++
> >  arch/x86/Kconfig                       |   1 +
> >  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
> >  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
> >  arch/x86/include/asm/intel_pconfig.h   |  42 ++++-
> >  arch/x86/include/asm/mktme.h           |  21 +++
> >  arch/x86/mm/mktme.c                    | 141 ++++++++++++++
> >  fs/exec.c                              |   4 +-
> >  include/keys/mktme-type.h              |  28 +++
> >  include/linux/key.h                    |   2 +
> >  include/linux/mm.h                     |   9 +-
> >  include/linux/syscalls.h               |   2 +
> >  include/uapi/asm-generic/unistd.h      |   4 +-
> >  kernel/fork.c                          |   2 +
> >  kernel/sys_ni.c                        |   2 +
> >  mm/mmap.c                              |  12 ++
> >  mm/mprotect.c                          |  93 +++++++++-
> >  mm/nommu.c                             |   4 +
> >  security/keys/Kconfig                  |  11 ++
> >  security/keys/Makefile                 |   1 +
> >  security/keys/internal.h               |   6 +
> >  security/keys/keyctl.c                 |   7 +
> >  security/keys/mktme_keys.c             | 325
> > +++++++++++++++++++++++++++++++++
> >  23 files changed, 855 insertions(+), 17 deletions(-)  create mode 100644
> > Documentation/x86/mktme-keys.txt  create mode 100644 include/keys/mktme-
> > type.h  create mode 100644 security/keys/mktme_keys.c
> > 
> > --
> > 2.14.1
> 
