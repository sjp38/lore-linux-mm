Message-ID: <49345086.4@cs.columbia.edu>
Date: Mon, 01 Dec 2008 16:00:54 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v10][PATCH 09/13] Restore open file descriprtors
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>	 <1227747884-14150-10-git-send-email-orenl@cs.columbia.edu>	 <20081128112745.GR28946@ZenIV.linux.org.uk>	 <1228159324.2971.74.camel@nimitz>  <49344C11.6090204@cs.columbia.edu> <1228164873.2971.95.camel@nimitz>
In-Reply-To: <1228164873.2971.95.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-api@vger.kernel.org, containers@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Al Viro <viro@ZenIV.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Mon, 2008-12-01 at 15:41 -0500, Oren Laadan wrote:
>>>>> +   fd = cr_attach_file(file);      /* no need to cleanup 'file' below */
>>>>> +   if (fd < 0) {
>>>>> +           filp_close(file, NULL);
>>>>> +           ret = fd;
>>>>> +           goto out;
>>>>> +   }
>>>>> +
>>>>> +   /* register new <objref, file> tuple in hash table */
>>>>> +   ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
>>>>> +   if (ret < 0)
>>>>> +           goto out;
>>>> Who said that file still exists at that point?
>> Correct. This call should move higher up befor ethe call to cr_attach_file()
> 
> Is that sufficient?  It seems like we're depending on the fd's reference
> to the 'struct file' to keep it valid in the hash.  If something happens
> to the fd (like the other thread messing with it) the 'struct file' can
> still go away.
> 
> Shouldn't we do another get_file() for the hash's reference?

When a shared object is inserted to the hash we automatically take another
reference to it (according to its type) for as long as it remains in the
hash. See:  'cr_obj_ref_grab()' and 'cr_obj_ref_drop()'.  So by moving that
call higher up, we protect the struct file.

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
