Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B205F6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:09:27 -0400 (EDT)
Received: by qyk15 with SMTP id 15so5441988qyk.12
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:09:35 -0700 (PDT)
Message-ID: <49D23224.9000903@codemonkey.ws>
Date: Tue, 31 Mar 2009 10:09:24 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random>
In-Reply-To: <20090331150218.GS9137@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Mar 31, 2009 at 09:37:17AM -0500, Anthony Liguori wrote:
>   
>> In the very least, if you insist on not using sysfs, you should have a 
>> separate character device that's used for control (like /dev/ksmctl).
>>     
>
> I'm fine to use sysfs that's not the point, if you've to add a ksmctl
> device, then sysfs is surely better. Besides ksm would normally be
> enabled at boot, tasks jailed by selinux will better not start/stop
> this thing.
>
> If people wants /sys/kernel/mm/ksm instead of the start_stop ioctl we
> surely can add it (provided there's a way to intercept write to the
> sysfs file). Problem is registering memory could also be done with
> 'echo 0 -1 >/proc/self/ksm' and be inherited by childs, it's not just
> start/stop. I mean this is more a matter of taste I'm
> afraid... Personally I'm more concerned about the registering of the
> ram API than the start/stop thing which I cannot care less about,

I don't think the registering of ram should be done via sysfs.  That 
would be a pretty bad interface IMHO.  But I do think the functionality 
that ksmctl provides along with the security issues I mentioned earlier 
really suggest that there ought to be a separate API for control vs. 
registration and that control API would make a lot of sense as a sysfs API.

If you wanted to explore alternative APIs for registration, madvise() 
seems like the obvious candidate to me.

madvise(start, size, MADV_SHARABLE) seems like a pretty obvious API to me.

So combining a sysfs interface for control and an madvise() interface 
for registration seems like a really nice interface to me.

Regards,

Anthony Liguori

>  so
> my logic is that as long as this pseudodevice exists, we should use it
> for everything. If we go away from it, then we should remove it as a
> whole.
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
