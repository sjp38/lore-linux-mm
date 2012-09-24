Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9698A6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 07:13:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 24 Sep 2012 16:43:50 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8OBDiN038207592
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 16:43:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8OBDhcq022508
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 21:13:44 +1000
Message-ID: <50604047.7000908@linux.vnet.ibm.com>
Date: Mon, 24 Sep 2012 16:43:11 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
References: <20120924102324.GA22303@aftab.osrc.amd.com> <50603829.9050904@linux.vnet.ibm.com> <20120924110554.GC22303@aftab.osrc.amd.com>
In-Reply-To: <20120924110554.GC22303@aftab.osrc.amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 09/24/2012 04:35 PM, Borislav Petkov wrote:
> On Mon, Sep 24, 2012 at 04:08:33PM +0530, Srivatsa S. Bhat wrote:
>> On 09/24/2012 03:53 PM, Borislav Petkov wrote:
>>> Hi all,
>>>
>>> we're able to trigger the oops below when doing CPU hotplug tests.
>>>
>>
>> I hit this problem as well, which I reported here, a few days ago:
>> https://lkml.org/lkml/2012/9/13/222
> 
> Ok, your case shows even more info:
> 
> [  526.024180] divide error: 0000 [#1] SMP 
> [  526.028144] Modules linked in: ipv6 cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf fuse loop dm_mod iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm cdc_ether pcspkr usbnet shpchp pci_hotplug i2c_i801 i2c_core ioatdma mii crc32c_intel serio_raw microcode lpc_ich mfd_core i7core_edac bnx2 dca edac_core tpm_tis tpm sg tpm_bios rtc_cmos button uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif edd ext3 mbcache jbd fan processor mptsas mptscsih mptbase scsi_transport_sas scsi_mod thermal thermal_sys hwmon
> [  526.028145] CPU 9 
> [  526.028145] Pid: 2235, comm: flush-8:0 Not tainted 3.6.0-rc1-tglx-hotplug-0.0.0.28.36b5ec9-default #1 IBM IBM System x -[7870C4Q]-/68Y8033 
> [  526.028145] RIP: 0010:[<ffffffff811276f6>]  [<ffffffff811276f6>] bdi_dirty_limit+0x66/0xc0
> [  526.028145] RSP: 0018:ffff8811530bfcc0  EFLAGS: 00010206
> [  526.028145] RAX: 0000000000b9877e RBX: 00000000001a8112 RCX: 28f5c28f5c28f5c3
> [  526.028145] RDX: 0000000000000000 RSI: 0000000000b9877e RDI: 0000000000000000
> 
> %rax contains something != 0 but %rdi definitely is 0.
> 

Yep.. So I tried putting a BUG_ON(!den) in fprop_fraction_percpu() to
catch if we really got the code wrong somehow.. but unfortunately, with
that added, I haven't been successful in reproducing the bug :(

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
