Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1384F6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 09:31:06 -0400 (EDT)
Received: by qyk15 with SMTP id 15so5336508qyk.12
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 06:31:35 -0700 (PDT)
Message-ID: <49D21B33.4070406@codemonkey.ws>
Date: Tue, 31 Mar 2009 08:31:31 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com>
In-Reply-To: <49D20B63.8020709@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
>
> I belive using ioctl for registering memory of applications make it 
> easier....

Yes, I completely agree.

> Ksm doesnt have any complicated API that would benefit from sysfs 
> (beside adding more complexity)
>
>> That is, the KSM_START_STOP_KTHREAD part, not necessarily the rest of 
>> the API.
>
> What you mean?

The ioctl(KSM_START_STOP_KTHREAD) API is distinct from the rest of the 
API.  Whereas the rest of the API is used by applications to register 
their memory with KSM, this API is used by ksmctl to allow parameters to 
be tweaked in userspace.

These parameters are just simple values like enable, pages_to_scan, 
sleep_time.  Then there is KSM_GET_INFO_KTHREAD which provides a read 
interface to these parameters.

You could drop KSM_START_STOP_KTHREAD and KSM_GET_INFO_KTHREAD 
altogether, and introduce a sysfs hierarchy:

/sysfs/<some/path>/ksm/{enable,pages_to_scan,sleep_time}

That eliminates the need for ksmctl altogether, cleanly separates the 
two APIs, and provides a stronger interface.

The main problem with the current API is that it uses a single device to 
do both the administrative task and the userspace interface.  That means 
that any application that has access to registering its memory with KSM 
also has the ability to disable KSM.  That seems like a security concern 
to me since registering a memory region ought to be an unprivileged 
action whereas enabling/disabling KSM ought to be a privileged action.

Regards,

Anthony Liguori

>>
>> Regards,
>>
>> Anthony Liguori
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
