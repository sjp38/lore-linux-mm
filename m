Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D66C96B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:12:40 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k126so5854524qke.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:12:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 101si8317622qkv.536.2017.08.07.12.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:12:40 -0700 (PDT)
Date: Mon, 7 Aug 2017 15:12:36 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
Message-ID: <20170807191235.GE16616@redhat.com>
References: <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
 <20170803135549.GW12521@dhcp22.suse.cz>
 <20170803144746.GA9501@redhat.com>
 <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
 <20170803151550.GX12521@dhcp22.suse.cz>
 <abe0c086-8c5a-d6fb-63c4-bf75528d0ec5@huawei.com>
 <20170804081240.GF26029@dhcp22.suse.cz>
 <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
 <20170807133107.GA16616@redhat.com>
 <555dc453-3028-199a-881a-3ddeb41e4d6d@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <555dc453-3028-199a-881a-3ddeb41e4d6d@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On Mon, Aug 07, 2017 at 05:13:00PM +0300, Igor Stoppa wrote:
> 
> 
> On 07/08/17 16:31, Jerome Glisse wrote:
> > On Mon, Aug 07, 2017 at 02:26:21PM +0300, Igor Stoppa wrote:
> 
> [...]
> 
> >> I'll add a vm_area field as you advised.
> >>
> >> Is this something I could send as standalone patch?
> > 
> > Note that vmalloc() is not the only thing that use vmalloc address
> > space. There is also vmap() and i know one set of drivers that use
> > vmap() and also use the mapping field of struct page namely GPU
> > drivers.
> 
> Ah, yes, you mentioned this.
> 
> > So like i said previously i would store a flag inside vm_struct to
> > know if page you are looking at are pmalloc or not.
> 
> And I was planning to follow your advice, using one of the flags.
> But ...
> 
> > Again do you
> > need to store something per page ? Would storing it per vm_struct
> > not be enough ?
> 
> ... there was this further comment, about speeding up the access to
> vm_area, which seemed good from performance perspective.
> 
> ---8<--------------8<--------------8<--------------8<--------------8<---
> On 03/08/17 14:48, Michal Hocko wrote:
> > On Thu 03-08-17 13:11:45, Igor Stoppa wrote:
> 
> [...]
> 
> >> But, to reply more specifically to your advice, yes, I think I could
> >> add a flag to vm_struct and then retrieve its value, for the address
> >> being processed, by passing through find_vm_area().
> >
> > ... and you can store vm_struct pointer to the struct page there and
> > you won't need to do the slow find_vm_area. I haven't checked very
> > closely but this should be possible in principle. I guess other
> > callers might benefit from this as well.
> ---8<--------------8<--------------8<--------------8<--------------8<---
> 
> I do not strictly need to modify the page struct, but it seems it might
> harm performance, if it is added on the path of hardened usercopy.
> 
> I have an updated version of the old proposal:
> 
> * put a magic number in the private field, during initialization of
> pmalloc pages
> 
> * during hardened usercopy verification, when I have to assess if a page
> is of pmalloc type, compare the private field against the magic number
> 
> * if and only if the private field matches the magic number, then invoke
> find_vm_area(), so that the slowness affects only a possibly limited
> amount of false positives.

This all sounds good to me.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
