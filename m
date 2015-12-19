Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id BAA8E4402ED
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 17:03:26 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id o11so3508027qge.2
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 14:03:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o97si22959961qgd.69.2015.12.19.14.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Dec 2015 14:03:26 -0800 (PST)
Subject: Re: [PATCH] mm, oom: initiallize all new zap_details fields before
 use
References: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
 <20151219195237.GA31380@node.shutemov.name>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5675D423.6020806@oracle.com>
Date: Sat, 19 Dec 2015 17:03:15 -0500
MIME-Version: 1.0
In-Reply-To: <20151219195237.GA31380@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/2015 02:52 PM, Kirill A. Shutemov wrote:
> On Fri, Dec 18, 2015 at 08:04:51PM -0500, Sasha Levin wrote:
>> > Commit "mm, oom: introduce oom reaper" forgot to initialize the two new fields
>> > of struct zap_details in unmap_mapping_range(). This caused using stack garbage
>> > on the call to unmap_mapping_range_tree().
>> > 
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> > ---
>> >  mm/memory.c |    1 +
>> >  1 file changed, 1 insertion(+)
>> > 
>> > diff --git a/mm/memory.c b/mm/memory.c
>> > index 206c8cd..0e32993 100644
>> > --- a/mm/memory.c
>> > +++ b/mm/memory.c
>> > @@ -2431,6 +2431,7 @@ void unmap_mapping_range(struct address_space *mapping,
>> >  	details.last_index = hba + hlen - 1;
>> >  	if (details.last_index < details.first_index)
>> >  		details.last_index = ULONG_MAX;
>> > +	details.check_swap_entries = details.ignore_dirty = false;
> Should we use c99 initializer instead to make it future-proof?

I didn't do that to make these sort of failures obvious. In this case, if we would have
used an initializer and it would default to the "wrong" values it would be much harder
to find this bug.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
