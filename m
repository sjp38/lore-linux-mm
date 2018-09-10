Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6DC8E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 21:28:37 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h4-v6so9224578pls.17
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 18:28:37 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y141-v6si16466546pfb.331.2018.09.09.18.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 18:28:35 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
Date: Mon, 10 Sep 2018 01:28:28 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935424996@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Alison Schofield
> Sent: Saturday, September 8, 2018 10:34 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
> Encryption API
>=20
> Document the API's used for MKTME on Intel platforms.
> MKTME: Multi-KEY Total Memory Encryption
>=20
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  Documentation/x86/mktme-keys.txt | 153
> +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 153 insertions(+)
>  create mode 100644 Documentation/x86/mktme-keys.txt
>=20
> diff --git a/Documentation/x86/mktme-keys.txt b/Documentation/x86/mktme-
> keys.txt
> new file mode 100644
> index 000000000000..2dea7acd2a17
> --- /dev/null
> +++ b/Documentation/x86/mktme-keys.txt
> @@ -0,0 +1,153 @@
> +MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> +memory encryption on Intel platforms. Whereas TME (Total Memory
> +Encryption) allows encryption of the entire system memory using a
> +single key, MKTME allows multiple encryption domains, each having their
> +own key. The main use case for the feature is virtual machine
> +isolation. The API's introduced here are intended to offer flexibility t=
o work in a
> wide range of uses.
> +
> +The externally available Intel Architecture Spec:
> +https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-
> +Total-Memory-Encryption-Spec.pdf
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D  API Overview
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> +
> +There are 2 MKTME specific API's that enable userspace to create and
> +use the memory encryption keys:
> +
> +1) Kernel Key Service: MKTME Type
> +
> +   MKTME is a new key type added to the existing Kernel Key Services
> +   to support the memory encryption keys. The MKTME service manages
> +   the addition and removal of MKTME keys. It maps userspace keys
> +   to hardware keyids and programs the hardware with user requested
> +   encryption parameters.
> +
> +   o An understanding of the Kernel Key Service is required in order
> +     to use the MKTME key type as it is a subset of that service.
> +
> +   o MKTME keys are a limited resource. There is a single pool of
> +     MKTME keys for a system and that pool can be from 3 to 63 keys.

Why 3 to 63 keys? Architecturally we are able to support up to 15-bit keyID=
, although in the first generation server we only support 6-bit keyID, whic=
h is 63 key/keyIDs (excluding keyID 0, which is TME's keyID).

> +     With that in mind, userspace may take advantage of the kernel
> +     key services sharing and permissions model for userspace keys.
> +     One key can be shared as long as each user has the permission
> +     of "KEY_NEED_VIEW" to use it.
> +
> +   o MKTME key type uses capabilities to restrict the allocation
> +     of keys. It only requires CAP_SYS_RESOURCE, but will accept
> +     the broader capability of CAP_SYS_ADMIN.  See capabilities(7).
> +
> +   o The MKTME key service blocks kernel key service commands that
> +     could lead to reprogramming of in use keys, or loss of keys from
> +     the pool. This means MKTME does not allow a key to be invalidated,
> +     unlinked, or timed out. These operations are blocked by MKTME as
> +     it creates all keys with the internal flag KEY_FLAG_KEEP.
> +
> +   o MKTME does not support the keyctl option of UPDATE. Userspace
> +     may change the programming of a key by revoking it and adding
> +     a new key with the updated encryption options (or vice-versa).
> +
> +2) System Call: encrypt_mprotect()
> +
> +   MKTME encryption is requested by calling encrypt_mprotect(). The
> +   caller passes the serial number to a previously allocated and
> +   programmed encryption key. That handle was created with the MKTME
> +   Key Service.
> +
> +   o The caller must have KEY_NEED_VIEW permission on the key
> +
> +   o The range of memory that is to be protected must be mapped as
> +     ANONYMOUS. If it is not, the entire encrypt_mprotect() request
> +     fails with EINVAL.
> +
> +   o As an extension to the existing mprotect() system call,
> +     encrypt_mprotect() supports the legacy mprotect behavior plus
> +     the enabling of memory encryption. That means that in addition
> +     to encrypting the memory, the protection flags will be updated
> +     as requested in the call.
> +
> +   o Additional mprotect() calls to memory already protected with
> +     MKTME will not alter the MKTME status.

I think it's better to separate encrypt_mprotect() into another doc so both=
 parts can be reviewed easier.

> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D  Usag=
e: MKTME Key Service
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +MKTME is enabled on supported Intel platforms by selecting
> +CONFIG_X86_INTEL_MKTME which selects CONFIG_MKTME_KEYS.
> +
> +Allocating MKTME Keys via command line or system call:
> +    keyctl add mktme name "[options]" ring
> +
> +    key_serial_t add_key(const char *type, const char *description,
> +                         const void *payload, size_t plen,
> +                         key_serial_t keyring);
> +
> +Revoking MKTME Keys via command line or system call::
> +   keyctl revoke <key>
> +
> +   long keyctl(KEYCTL_REVOKE, key_serial_t key);
> +
> +Options Field Definition:
> +    userkey=3D      ASCII HEX value encryption key. Defaults to a CPU
> +		  generated key if a userkey is not defined here.
> +
> +    algorithm=3D    Encryption algorithm name as a string.
> +		  Valid algorithm: "aes-xts-128"
> +
> +    tweak=3D        ASCII HEX value tweak key. Tweak key will be added t=
o the
> +                  userkey...  (need to be clear here that this is being =
sent
> +                  to the hardware - kernel not messing w it)
> +
> +    entropy=3D      ascii hex value entropy.
> +                  This entropy will be used to generated the CPU key and
> +		  the tweak key when CPU generated key is requested.
> +
> +Algorithm Dependencies:
> +    AES-XTS 128 is the only supported algorithm.
> +    There are only 2 ways that AES-XTS 128 may be used:
> +
> +    1) User specified encryption key
> +	- The user specified encryption key must be exactly
> +	  16 ASCII Hex bytes (128 bits).
> +	- A tweak key must be specified and it must be exactly
> +	  16 ASCII Hex bytes (128 bits).
> +	- No entropy field is accepted.
> +
> +    2) CPU generated encryption key
> +	- When no user specified encryption key is provided, the
> +	  default encryption key will be CPU generated.
> +	- User must specify 16 ASCII Hex bytes of entropy. This
> +	  entropy will be used by the CPU to generate both the
> +	  encryption key and the tweak key.
> +	- No entropy field is accepted.

This is not true. The spec says in CPU generated random mode, both 'key' an=
d 'tweak' part are used to generate the final key and tweak respectively.

Actually, simple 'XOR' is used to generate the final key:

case KEYID_SET_KEY_RANDOM:
	......
	(* Mix user supplied entropy to the data key and tweak key *)
	TMP_RND_DATA_KEY =3D TMP_RND_KEY XOR
		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_1.BYTES[15:0];
	TMP_RND_TWEAK_KEY =3D TMP_RND_TWEAK_KEY XOR
		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_2.BYTES[15:0];

So I think we can either just remove 'entropy' parameter, since we can use =
both 'userkey' and 'tweak' even for random key mode.

In fact, which might be better IMHO, we can simply disallow or ignore 'user=
key' and 'tweak' part for random key mode, since if we allow user to specif=
y both entropies, and if user passes value with all 1, we are effectively m=
aking the key and tweak to be all 1, which is not random anymore.

Instead, kernel can generate random for both entropies, or we can simply us=
es 0, ignoring user input.

Thanks,
-Kai
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D  Usag=
e: encrypt_mprotect()
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +System Call encrypt_mprotect()::
> +
> +    This system call is an extension of the existing mprotect() system
> +    call. It requires the same parameters as legary mprotect() plus
> +    one additional parameter, the keyid. Userspace must provide the
> +    key serial number assigned through the kernel key service.
> +
> +    int encrypt_mprotect(void *addr, size_t len, int prot, int keyid);
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D  Usag=
e: Sample Roundtrip
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Sample usage of MKTME Key Service API with encrypt_mprotect() API:
> +
> +  Add a key:
> +        key =3D add_key(mktme, name, options, strlen(option), keyring);
> +
> +  Map memory:
> +        ptr =3D mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0)=
;
> +
> +  Protect memory:
> +        ret =3D syscall(sys_encrypt_mprotect, ptr, size, prot, keyid);
> +
> +  Use protected memory:
> +        ................
> +
> +  Free memory:
> +        ret =3D munmap(ptr, size);
> +
> +  Revoke key:
> +        ret =3D keyctl(KEYCTL_REVOKE, key);
> +
> --
> 2.14.1
