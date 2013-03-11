Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8E9996B0005
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 00:58:49 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wd20so2891243obb.23
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 21:58:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130311025534.GA1185@kroah.com>
References: <513D3EA9.4010308@cn.fujitsu.com>
	<20130311025534.GA1185@kroah.com>
Date: Mon, 11 Mar 2013 12:58:48 +0800
Message-ID: <CAJd=RBAf4rFAxp9aggrAccQQk2XqJhPO73bjceUEsnGg8F+iTA@mail.gmail.com>
Subject: Re: sysfs: Kernel OOPS when install and remove modules
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Gao feng <gaofeng@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Mar 11, 2013 at 10:55 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Mon, Mar 11, 2013 at 10:17:13AM +0800, Gao feng wrote:
>> I get the below stack when I execute the shell program
>>
>> #!/bin/bash
>>
>> while :;
>> do
>> modprobe 8139too&
>> rmmod 8139too&
>> done
>>
>> I trust it is not the problem of 8139too, the other modules have the same problems too.
>> Is this an already known problem?
>>
>> [   53.328212] 8139too: 8139too Fast Ethernet driver 0.9.28
>> [   53.368029] 8139too: module is already loaded
>> [   53.456339] 8139too: 8139too Fast Ethernet driver 0.9.28
>> [   53.510611] 8139too: 8139too Fast Ethernet driver 0.9.28
>> [   53.551713] ------------[ cut here ]------------
>> [   53.551721] WARNING: at include/linux/kref.h:42 kobject_get+0x33/0x40()
>> [   53.551722] Hardware name: Bochs
>> [   53.551723] Modules linked in: 8139too(+) ebtable_nat ipt_MASQUERADE nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat
>> iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter bnep ebtables bluetooth rfkill ip6table_filter ip6_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4
>> cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device
>> snd_pcm snd_page_alloc snd_timer microcode snd i2c_piix4 virtio_balloon 8139cp soundcore mii i2c_core uinput [last unloaded: 8139too]
>> [   53.551757] Pid: 1158, comm: modprobe Not tainted 3.6.10-4.fc18.x86_64 #1
>
> Does this happen on a kernel.org kernel release?
>
> There's nothing I can do with a fedora kernel, sorry.
>
The comment says
/**
 * kref_put - decrement refcount for object.
 * @kref: object.
 * @release: pointer to the function that will clean up the object when the
 *	     last reference to the object is released.
 *	     This pointer is required, and it is not acceptable to pass kfree
 *	     in as this function.  If the caller does pass kfree to this
 *	     function, you will be publicly mocked mercilessly by the kref
 *	     maintainer, and anyone else who happens to notice it.  You have
 *	     been warned.
 *
 * Decrement the refcount, and if 0, call release().
 * Return 1 if the object was removed, otherwise return 0.  Beware, if this
 * function returns 0, you still can not count on the kref from remaining in
 * memory.  Only use the return value if you want to see if the kref is now
 * gone, not present.
 */

and the release callback is called too late since we have to
/* remove the kobject from its kset's list */ even if refcount
drops to zero.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
