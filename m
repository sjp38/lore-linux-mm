Message-ID: <491A07D4.2020001@redhat.com>
Date: Wed, 12 Nov 2008 00:31:48 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<1226409701-14831-2-git-send-email-ieidus@redhat.com>	<1226409701-14831-3-git-send-email-ieidus@redhat.com>	<1226409701-14831-4-git-send-email-ieidus@redhat.com>	<20081111150345.7fff8ff2@bike.lwn.net>	<491A0483.3010504@redhat.com> <20081111152527.3c55bd6d@bike.lwn.net>
In-Reply-To: <20081111152527.3c55bd6d@bike.lwn.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

Jonathan Corbet wrote:
> On Wed, 12 Nov 2008 00:17:39 +0200
> Izik Eidus <ieidus@redhat.com> wrote:
>
>   
>>>> +static int ksm_dev_open(struct inode *inode, struct file *filp)
>>>> +{
>>>> +	try_module_get(THIS_MODULE);
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int ksm_dev_release(struct inode *inode, struct file *filp)
>>>> +{
>>>> +	module_put(THIS_MODULE);
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static struct file_operations ksm_chardev_ops = {
>>>> +	.open           = ksm_dev_open,
>>>> +	.release        = ksm_dev_release,
>>>> +	.unlocked_ioctl = ksm_dev_ioctl,
>>>> +	.compat_ioctl   = ksm_dev_ioctl,
>>>> +};
>>>>       
>>>>         
>>> Why do you roll your own module reference counting?  Is there a
>>> reason you don't just set .owner and let the VFS handle it?
>>>     
>>>       
>> Yes, I am taking get_task_mm() if the module will be removed before i 
>> free the mms, things will go wrong
>>     
>
> But...if you set .owner, the VFS will do the try_module_get() *before*
> calling into your module (as an added bonus, it will actually check the
> return value too).  
Ohhh i see what you mean
you are right i had at least needed to check for the return value of 
try_module_get(),
anyway will check this issue for V2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
