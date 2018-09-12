Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFA28E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:12:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id a70-v6so1263213qkb.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 04:12:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r56-v6si520745qvr.217.2018.09.12.04.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 04:12:47 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <e8f43039bf904d0547a9fdc1f6da515747305a59.1536356108.git.alison.schofield@intel.com>
References: <e8f43039bf904d0547a9fdc1f6da515747305a59.1536356108.git.alison.schofield@intel.com> <cover.1536356108.git.alison.schofield@intel.com>
Subject: Re: [RFC 12/12] keys/mktme: Do not revoke in use memory encryption keys
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <17535.1536750763.1@warthog.procyon.org.uk>
Date: Wed, 12 Sep 2018 12:12:43 +0100
Message-ID: <17536.1536750763@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Alison Schofield <alison.schofield@intel.com> wrote:

> +
> +	if (strcmp(key->type->name, "mktme") == 0)
> +		mktme_revoke_key(key);
> +

*Please* don't do that.

The core code shouldn't be making references to specific key types in this
way.  The only reason this is necessary for encrypted and trusted keys is
because they misused the ->update() hook and it took a while for this to be
noticed.

> The KEY_FLAG_KEEP bit offers good control. The mktme service uses
> that flag to prevent userspace keys from going away without proper
> synchronization with the mktme service type.

This is not the control you are looking for.  The point of KEY_FLAG_KEEP is to
allow the system to pin a key.  It's not meant to be a flag for the key type
to play with.

You say this:

	One example is that userspace keys should not be revoked while the
	hardware keyid slot is still in use.

but why not?  Revoking it causes accesses to return -EKEYREVOKED; it doesn't
stop the kernel from using the key.

Also, note that you don't *have* to provide a ->revoke() operation

If you really want to suppress revocation, then I would suggest adding another
type operation, say ->may_revoke(), that says whether you're allowed to do
that.

David
