Received: from zaphod.GDImbH.com (zaphod.GDImbH.com [194.115.68.214])
	by sharon.GDImbH.com (8.9.3/8.9.3) with ESMTP id LAA06773
	for <linux-mm@kvack.org>; Wed, 21 Nov 2001 11:19:13 +0100
Received: (from ralf@localhost)
	by zaphod.GDImbH.com (8.11.2/8.11.2/SuSE Linux 8.11.1-0.5) id fALAJD306894
	for linux-mm@kvack.org; Wed, 21 Nov 2001 11:19:13 +0100
Message-ID: <XFMail.20011121111913.R.Oehler@GDImbH.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Date: Wed, 21 Nov 2001 11:19:13 +0100 (MET)
Reply-To: R.Oehler@GDImbH.com
From: R.Oehler@GDImbH.com
Subject: recursive lock-enter-deadlock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A short question (I don't have a recent 2.4.x at hand, currently):

Is this recursive lock-enter-deadlock (2.4.0) fixed in newer kernels?

Regards,
        Ralf





void truncate_inode_pages(struct address_space * mapping, loff_t lstart) 
{
        unsigned long start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
        unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);

repeat:
        spin_lock(&pagecache_lock);
        if (truncate_list_pages(&mapping->clean_pages, start, &partial))
                goto repeat;
        if (truncate_list_pages(&mapping->dirty_pages, start, &partial))
                goto repeat;
        if (truncate_list_pages(&mapping->locked_pages, start, &partial))
                goto repeat;
        spin_unlock(&pagecache_lock);
}

 -----------------------------------------------------------------
|  Ralf Oehler
|  GDI - Gesellschaft fuer Digitale Informationstechnik mbH
|
|  E-Mail:      R.Oehler@GDImbH.com
|  Tel.:        +49 6182-9271-23 
|  Fax.:        +49 6182-25035           
|  Mail:        GDI, Bensbruchstrasse 11, D-63533 Mainhausen
|  HTTP:        www.GDImbH.com
 -----------------------------------------------------------------

time is a funny concept

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
