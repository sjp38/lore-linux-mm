Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09DFC8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:12:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c8-v6so11930582pfn.2
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:12:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cd2-v6si19402989plb.47.2018.09.10.17.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:12:29 -0700 (PDT)
Date: Mon, 10 Sep 2018 17:13:01 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
Message-ID: <20180911001301.GB31868@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424996@PGSMSX112.gar.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <105F7BF4D0229846AF094488D65A098935424996@PGSMSX112.gar.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Sep 09, 2018 at 06:28:28PM -0700, Huang, Kai wrote:
> 
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Alison Schofield
> > Sent: Saturday, September 8, 2018 10:34 AM
> > To: dhowells@redhat.com; tglx@linutronix.de
> > Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> > <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> > Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> > <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> > linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> > x86@kernel.org; linux-mm@kvack.org
> > Subject: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
> > Encryption API
> > 
> > Document the API's used for MKTME on Intel platforms.
> > MKTME: Multi-KEY Total Memory Encryption
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > ---
> >  Documentation/x86/mktme-keys.txt | 153
> > +++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 153 insertions(+)
> >  create mode 100644 Documentation/x86/mktme-keys.txt
> > 
> > diff --git a/Documentation/x86/mktme-keys.txt b/Documentation/x86/mktme-
> > keys.txt
> > new file mode 100644
> > index 000000000000..2dea7acd2a17
> > --- /dev/null
> > +++ b/Documentation/x86/mktme-keys.txt
> > @@ -0,0 +1,153 @@
> > +MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> > +memory encryption on Intel platforms. Whereas TME (Total Memory
> > +Encryption) allows encryption of the entire system memory using a
> > +single key, MKTME allows multiple encryption domains, each having their
> > +own key. The main use case for the feature is virtual machine
> > +isolation. The API's introduced here are intended to offer flexibility to work in a
> > wide range of uses.
> > +
> > +The externally available Intel Architecture Spec:
> > +https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-
> > +Total-Memory-Encryption-Spec.pdf
> > +
> > +============================  API Overview
> > +============================
> > +
> > +There are 2 MKTME specific API's that enable userspace to create and
> > +use the memory encryption keys:
> > +
> > +1) Kernel Key Service: MKTME Type
> > +
> > +   MKTME is a new key type added to the existing Kernel Key Services
> > +   to support the memory encryption keys. The MKTME service manages
> > +   the addition and removal of MKTME keys. It maps userspace keys
> > +   to hardware keyids and programs the hardware with user requested
> > +   encryption parameters.
> > +
> > +   o An understanding of the Kernel Key Service is required in order
> > +     to use the MKTME key type as it is a subset of that service.
> > +
> > +   o MKTME keys are a limited resource. There is a single pool of
> > +     MKTME keys for a system and that pool can be from 3 to 63 keys.
> 
> Why 3 to 63 keys? Architecturally we are able to support up to 15-bit keyID, although in the first generation server we only support 6-bit keyID, which is 63 key/keyIDs (excluding keyID 0, which is TME's keyID).

My understanding is that low level SKU's could have as few as 3 bits 
available to hold the keyid, and that the max is 6 bits, hence 64.
I probably don't need to be stating that level of detail here, but
rather just iterate the important point that the resource is limited!

> 
> > +     With that in mind, userspace may take advantage of the kernel
> > +     key services sharing and permissions model for userspace keys.
> > +     One key can be shared as long as each user has the permission
> > +     of "KEY_NEED_VIEW" to use it.
> > +
> > +   o MKTME key type uses capabilities to restrict the allocation
> > +     of keys. It only requires CAP_SYS_RESOURCE, but will accept
> > +     the broader capability of CAP_SYS_ADMIN.  See capabilities(7).
> > +
> > +   o The MKTME key service blocks kernel key service commands that
> > +     could lead to reprogramming of in use keys, or loss of keys from
> > +     the pool. This means MKTME does not allow a key to be invalidated,
> > +     unlinked, or timed out. These operations are blocked by MKTME as
> > +     it creates all keys with the internal flag KEY_FLAG_KEEP.
> > +
> > +   o MKTME does not support the keyctl option of UPDATE. Userspace
> > +     may change the programming of a key by revoking it and adding
> > +     a new key with the updated encryption options (or vice-versa).
> > +
> > +2) System Call: encrypt_mprotect()
> > +
> > +   MKTME encryption is requested by calling encrypt_mprotect(). The
> > +   caller passes the serial number to a previously allocated and
> > +   programmed encryption key. That handle was created with the MKTME
> > +   Key Service.
> > +
> > +   o The caller must have KEY_NEED_VIEW permission on the key
> > +
> > +   o The range of memory that is to be protected must be mapped as
> > +     ANONYMOUS. If it is not, the entire encrypt_mprotect() request
> > +     fails with EINVAL.
> > +
> > +   o As an extension to the existing mprotect() system call,
> > +     encrypt_mprotect() supports the legacy mprotect behavior plus
> > +     the enabling of memory encryption. That means that in addition
> > +     to encrypting the memory, the protection flags will be updated
> > +     as requested in the call.
> > +
> > +   o Additional mprotect() calls to memory already protected with
> > +     MKTME will not alter the MKTME status.
> 
> I think it's better to separate encrypt_mprotect() into another doc so both parts can be reviewed easier.

I can do that.
Also, I do know I need man page for that too.
> 
> > +
> > +======================  Usage: MKTME Key Service
> > +======================
> > +
> > +MKTME is enabled on supported Intel platforms by selecting
> > +CONFIG_X86_INTEL_MKTME which selects CONFIG_MKTME_KEYS.
> > +
> > +Allocating MKTME Keys via command line or system call:
> > +    keyctl add mktme name "[options]" ring
> > +
> > +    key_serial_t add_key(const char *type, const char *description,
> > +                         const void *payload, size_t plen,
> > +                         key_serial_t keyring);
> > +
> > +Revoking MKTME Keys via command line or system call::
> > +   keyctl revoke <key>
> > +
> > +   long keyctl(KEYCTL_REVOKE, key_serial_t key);
> > +
> > +Options Field Definition:
> > +    userkey=      ASCII HEX value encryption key. Defaults to a CPU
> > +		  generated key if a userkey is not defined here.
> > +
> > +    algorithm=    Encryption algorithm name as a string.
> > +		  Valid algorithm: "aes-xts-128"
> > +
> > +    tweak=        ASCII HEX value tweak key. Tweak key will be added to the
> > +                  userkey...  (need to be clear here that this is being sent
> > +                  to the hardware - kernel not messing w it)
> > +
> > +    entropy=      ascii hex value entropy.
> > +                  This entropy will be used to generated the CPU key and
> > +		  the tweak key when CPU generated key is requested.
> > +
> > +Algorithm Dependencies:
> > +    AES-XTS 128 is the only supported algorithm.
> > +    There are only 2 ways that AES-XTS 128 may be used:
> > +
> > +    1) User specified encryption key
> > +	- The user specified encryption key must be exactly
> > +	  16 ASCII Hex bytes (128 bits).
> > +	- A tweak key must be specified and it must be exactly
> > +	  16 ASCII Hex bytes (128 bits).
> > +	- No entropy field is accepted.
> > +
> > +    2) CPU generated encryption key
> > +	- When no user specified encryption key is provided, the
> > +	  default encryption key will be CPU generated.
> > +	- User must specify 16 ASCII Hex bytes of entropy. This
> > +	  entropy will be used by the CPU to generate both the
> > +	  encryption key and the tweak key.
> > +	- No entropy field is accepted.
             ^^^^^^^ should be tweak

> 
> This is not true. The spec says in CPU generated random mode, both 'key' and 'tweak' part are used to generate the final key and tweak respectively.
> 
> Actually, simple 'XOR' is used to generate the final key:
> 
> case KEYID_SET_KEY_RANDOM:
> 	......
> 	(* Mix user supplied entropy to the data key and tweak key *)
> 	TMP_RND_DATA_KEY = TMP_RND_KEY XOR
> 		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_1.BYTES[15:0];
> 	TMP_RND_TWEAK_KEY = TMP_RND_TWEAK_KEY XOR
> 		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_2.BYTES[15:0];
> 
> So I think we can either just remove 'entropy' parameter, since we can use both 'userkey' and 'tweak' even for random key mode.
> 
> In fact, which might be better IMHO, we can simply disallow or ignore 'userkey' and 'tweak' part for random key mode, since if we allow user to specify both entropies, and if user passes value with all 1, we are effectively making the key and tweak to be all 1, which is not random anymore.
> 
> Instead, kernel can generate random for both entropies, or we can simply uses 0, ignoring user input.

Kai,
I think my typo above, threw you off. We have the same understanding of
the key fields.

Is this the structure you are suggesting?

	Options

	key_type=	"user" or "CPU"

	key=		If key_type == user
				key= is the data key
			If key_type == CPU
				key= is not required
				if key= is present
					it is entropy to be mixed with
					CPU generated data key

	tweak=		If key_type == user
				tweak= is the tweak key
			If key_type == CPU
				tweak= is not required
				if tweak= is present
					it is entropy to be mixed with
					CPU generated tweak key


Alison
> 
> Thanks,
> -Kai

........snip...........
