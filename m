Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEFF16B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:09:28 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id z32so4588807ota.5
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:09:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j93si7085506otc.326.2017.12.22.08.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:09:28 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <936b9c5c-a7b2-4f11-c049-00b3cb0985cc@redhat.com>
Date: Fri, 22 Dec 2017 17:09:23 +0100
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-9-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>, =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>, Marian Rotariu <mrotariu@bitdefender.com>

On 18/12/2017 20:06, Adalber LazA?r wrote:
> +	print_hex_dump_debug("kvmi: new token ", DUMP_PREFIX_NONE,
> +			     32, 1, token, sizeof(struct kvmi_map_mem_token),
> +			     false);
> +
> +	tep = kmalloc(sizeof(struct token_entry), GFP_KERNEL);
> +	if (tep == NULL)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&tep->token_list);
> +	memcpy(&tep->token, token, sizeof(struct kvmi_map_mem_token));
> +	tep->kvm = kvm;
> +
> +	spin_lock(&token_lock);
> +	list_add_tail(&tep->token_list, &token_list);
> +	spin_unlock(&token_lock);
> +
> +	return 0;

This allows unlimited allocations on the host from the introspector
guest.  You must only allow a fixed number of unconsumed tokens (e.g. 64).

Thanks,

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
