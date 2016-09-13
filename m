Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5A346B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 12:21:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n24so171071pfb.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:21:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w25si11455884pfg.107.2016.09.13.09.21.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 09:21:19 -0700 (PDT)
Subject: Re: [PATCH v2] mm, proc: Fix region lost in /proc/self/smaps
References: <1473649964-20191-1-git-send-email-guangrong.xiao@linux.intel.com>
 <20160912125447.GM14524@dhcp22.suse.cz> <57D6C332.4000409@intel.com>
 <20160912191035.GD14997@dhcp22.suse.cz> <20160913145906.GA28037@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D8277E.80505@intel.com>
Date: Tue, 13 Sep 2016 09:21:18 -0700
MIME-Version: 1.0
In-Reply-To: <20160913145906.GA28037@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/13/2016 07:59 AM, Oleg Nesterov wrote:
> On 09/12, Michal Hocko wrote:
>> > Considering how this all can be tricky and how partial reads can be
>> > confusing and even misleading I am really wondering whether we
>> > should simply document that only full reads will provide a sensible
>> > results.
> I agree. I don't even understand why this was considered as a bug.
> Obviously, m_stop() which drops mmap_sep should not be called, or
> all the threads should be stopped, if you want to trust the result.

There was a mapping at a given address.  That mapping did not change, it
was not split, its attributes did not change.  But, it didn't show up
when reading smaps.  Folks _actually_ noticed this in a test suite
looking for that address range in smaps.

IOW, we had goofy kernel behavior, and it broke a reasonable test
program.  The test program just used fgets() to read into a fixed-length
buffer, which is a completely normal thing to do.

To get "sensible results", doesn't userspace have to somehow know in
advance how many bytes of data a given VMA will generate in smaps output?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
