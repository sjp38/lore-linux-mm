Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13B8C8E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 14:44:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a26-v6so8635131pgw.7
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 11:44:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s7-v6si12956257pgj.480.2018.09.08.11.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 08 Sep 2018 11:44:25 -0700 (PDT)
Subject: Re: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
References: <cover.1536356108.git.alison.schofield@intel.com>
 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b821cd4c-b061-3ea0-b0af-992d844ddad5@infradead.org>
Date: Sat, 8 Sep 2018 11:44:19 -0700
MIME-Version: 1.0
In-Reply-To: <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>, dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

On 09/07/2018 03:34 PM, Alison Schofield wrote:
> Document the API's used for MKTME on Intel platforms.
> MKTME: Multi-KEY Total Memory Encryption
> 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>

Hi,
A few comments below...

> ---
>  Documentation/x86/mktme-keys.txt | 153 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 153 insertions(+)
>  create mode 100644 Documentation/x86/mktme-keys.txt
> 
> diff --git a/Documentation/x86/mktme-keys.txt b/Documentation/x86/mktme-keys.txt
> new file mode 100644
> index 000000000000..2dea7acd2a17
> --- /dev/null
> +++ b/Documentation/x86/mktme-keys.txt
> @@ -0,0 +1,153 @@
> +MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> +memory encryption on Intel platforms. Whereas TME (Total Memory Encryption)
> +allows encryption of the entire system memory using a single key, MKTME
> +allows multiple encryption domains, each having their own key. The main use
> +case for the feature is virtual machine isolation. The API's introduced here
> +are intended to offer flexibility to work in a wide range of uses.
> +
> +The externally available Intel Architecture Spec:
> +https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
> +
> +============================  API Overview  ============================
> +
> +There are 2 MKTME specific API's that enable userspace to create and use
> +the memory encryption keys:
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

reference available?

> +
> +   o MKTME keys are a limited resource. There is a single pool of
> +     MKTME keys for a system and that pool can be from 3 to 63 keys.
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

                                                             key.

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
> +
> +======================  Usage: MKTME Key Service  ======================
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
> +    userkey=      ASCII HEX value encryption key. Defaults to a CPU
> +		  generated key if a userkey is not defined here.
> +
> +    algorithm=    Encryption algorithm name as a string.
> +		  Valid algorithm: "aes-xts-128"
> +
> +    tweak=        ASCII HEX value tweak key. Tweak key will be added to the
> +                  userkey...  (need to be clear here that this is being sent
> +                  to the hardware - kernel not messing w it)

                                                          with it)

> +
> +    entropy=      ascii hex value entropy.

                     ASCII

> +                  This entropy will be used to generated the CPU key and

                                               to generate the

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

above line ends with a space.  Please drop it.

> +	  entropy will be used by the CPU to generate both the
> +	  encryption key and the tweak key.
> +	- No entropy field is accepted.
> +
> +======================  Usage: encrypt_mprotect()  ======================
> +
> +System Call encrypt_mprotect()::
> +
> +    This system call is an extension of the existing mprotect() system
> +    call. It requires the same parameters as legary mprotect() plus

                                                legacy

> +    one additional parameter, the keyid. Userspace must provide the
> +    key serial number assigned through the kernel key service.
> +
> +    int encrypt_mprotect(void *addr, size_t len, int prot, int keyid);
> +
> +======================  Usage: Sample Roundtrip  ======================
> +
> +Sample usage of MKTME Key Service API with encrypt_mprotect() API:
> +
> +  Add a key:
> +        key = add_key(mktme, name, options, strlen(option), keyring);

                                               strlen(options),

> +
> +  Map memory:
> +        ptr = mmap(NULL, size, prot, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
> +
> +  Protect memory:
> +        ret = syscall(sys_encrypt_mprotect, ptr, size, prot, keyid);
> +
> +  Use protected memory:
> +        ................
> +
> +  Free memory:
> +        ret = munmap(ptr, size);
> +
> +  Revoke key:
> +        ret = keyctl(KEYCTL_REVOKE, key);
> +
> 


-- 
~Randy
