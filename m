Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E09E18E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 21:10:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bh1-v6so9278352plb.15
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 18:10:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r21-v6si15260853pgi.690.2018.09.09.18.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 18:10:24 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 00/12] Multi-Key Total Memory Encryption API (MKTME)
Date: Mon, 10 Sep 2018 01:10:19 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935424961@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> -----Original Message-----
> From: keyrings-owner@vger.kernel.org [mailto:keyrings-
> owner@vger.kernel.org] On Behalf Of Alison Schofield
> Sent: Saturday, September 8, 2018 10:23 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 00/12] Multi-Key Total Memory Encryption API (MKTME)
>=20
> Seeking comments on the APIs supporting MKTME on future Intel platforms.
>=20
> MKTME (Multi-Key Total Memory Encryption) is a technology supporting
> memory encryption on upcoming Intel platforms. Whereas TME allows
> encryption of the entire system memory using a single key, MKTME allows
> mulitple encryption domains, each having their own key. While the main us=
e
> case for the feature is virtual machine isolation, the API needs the flex=
ibility to
> work for a wide range of use cases.
>=20
> This RFC presents the 2 API additions that enable userspace to:
>  1) Create Encryption Keys: Kernel Key Service type "mktme"
>  2) Use the Encryption Keys: system call encrypt_mprotect()
>=20
> In order to share between: the Kernel Key Service, the new system call, a=
nd the
> existing mm code, helper functions were created in arch/x86/mktme

IMHO, we can separate this series into 2 parts, as you did above, and send =
out them separately. The reason is, in general I think adding new MKTME typ=
e to key retention services is not that related to memory management code, =
namely the encrypt_mprotect() API part.

So if we split the two parts and send them out separately, the first part c=
an be reviewed by keyring and security guys, without involving mm guys, and=
 the encrypt_mprotect() part can be more reviewed more by mm guys.=20

And since encrypt_mprotect() is a new syscall, you may need to add more lis=
ts for the review, ie, linux-api, and maybe linux-kernel as well.

Thanks,
-Kai

>=20
> This patchset is built upon Kirill Shutemov's patchset for the core MKTME
> support. You can find that here:
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git mktme/wip
>=20
>=20
> Alison Schofield (12):
>   docs/x86: Document the Multi-Key Total Memory Encryption API
>   mm: Generalize the mprotect implementation to support extensions
>   syscall/x86: Wire up a new system call for memory encryption keys
>   x86/mm: Add helper functions to manage memory encryption keys
>   x86/mm: Add a helper function to set keyid bits in encrypted VMA's
>   mm: Add the encrypt_mprotect() system call
>   x86/mm: Add helper functions to track encrypted VMA's
>   mm: Track VMA's in use for each memory encryption keyid
>   mm: Restrict memory encryption to anonymous VMA's
>   x86/pconfig: Program memory encryption keys on a system-wide basis
>   keys/mktme: Add a new key service type for memory encryption keys
>   keys/mktme: Do not revoke in use memory encryption keys
>=20
>  Documentation/x86/mktme-keys.txt       | 153 ++++++++++++++++
>  arch/x86/Kconfig                       |   1 +
>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>  arch/x86/include/asm/intel_pconfig.h   |  42 ++++-
>  arch/x86/include/asm/mktme.h           |  21 +++
>  arch/x86/mm/mktme.c                    | 141 ++++++++++++++
>  fs/exec.c                              |   4 +-
>  include/keys/mktme-type.h              |  28 +++
>  include/linux/key.h                    |   2 +
>  include/linux/mm.h                     |   9 +-
>  include/linux/syscalls.h               |   2 +
>  include/uapi/asm-generic/unistd.h      |   4 +-
>  kernel/fork.c                          |   2 +
>  kernel/sys_ni.c                        |   2 +
>  mm/mmap.c                              |  12 ++
>  mm/mprotect.c                          |  93 +++++++++-
>  mm/nommu.c                             |   4 +
>  security/keys/Kconfig                  |  11 ++
>  security/keys/Makefile                 |   1 +
>  security/keys/internal.h               |   6 +
>  security/keys/keyctl.c                 |   7 +
>  security/keys/mktme_keys.c             | 325
> +++++++++++++++++++++++++++++++++
>  23 files changed, 855 insertions(+), 17 deletions(-)  create mode 100644
> Documentation/x86/mktme-keys.txt  create mode 100644 include/keys/mktme-
> type.h  create mode 100644 security/keys/mktme_keys.c
>=20
> --
> 2.14.1
