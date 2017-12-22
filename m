Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D63686B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 09:31:08 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f26so1680505iob.13
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 06:31:08 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o67si7164590itb.7.2017.12.22.06.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 06:31:07 -0800 (PST)
Subject: Re: [RFC PATCH v4 02/18] add memory map/unmap support for VM
 introspection on the guest side
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-3-alazar@bitdefender.com>
 <61ea8939-3826-8d8b-0ba0-5f0cbc434543@oracle.com>
 <186bce2ec7e54a679878e2c8fd97e805@mb1xmail.bitdefender.biz>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <11905cff-e920-382f-b3de-3cf02dbc0cc8@oracle.com>
Date: Fri, 22 Dec 2017 09:30:56 -0500
MIME-Version: 1.0
In-Reply-To: <186bce2ec7e54a679878e2c8fd97e805@mb1xmail.bitdefender.biz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mircea CIRJALIU-MELIU <mcirjaliu@bitdefender.com>, =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>

*snip*

>> +		pr_err("kvmi: address %016lx not mapped\n", vaddr);
>> +		return -ENOENT;
>> +	}
>> +
>> +	/* decouple guest mapping */
>> +	list_del(&pmp->map_list);
>> +	mutex_unlock(&fmp->lock);
> 
> In kvm_dev_ioctl_map(), the fmp mutex is held across the _do_mapping() call. Is there any particular reason why here the mutex doesn't need to be held across the _do_unmapping() call? Or was that more an artifact of having a common "out_err" exit in kvm_dev_ioctl_map()?
> 
> The fmp mutex:
> 1. protects the fmp list against concurrent access.
> 2. protects against teardown (one thread tries to do a mapping while another closes the file).
> The call to _do_mapping() - which can fail, must be done inside the critical section before we add a valid pmp entry to the list.
> On the other hand, inside kvm_dev_ioctl_unmap() we must extract a valid pmp entry from the list before calling _do_unmapping().
> There is no real reason for protecting the _do_mapping() call, but I chose not to revert the mapping in case I hit the teardown case.
>

Gotcha. That makes sense.


Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
